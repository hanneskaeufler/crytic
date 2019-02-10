require "compiler/crystal/syntax/*"
require "digest"
require "file_utils"

module Crytic::Mutation
  class InjectMutatedSubjectIntoSpecs < Crystal::Visitor
    # Because the class is used and instantiated multiple times, but these are
    # class vars, they need to be reset :(
    def self.reset
      @@already_parsed_file_name = Set(String).new
      @@file_list = [] of InjectMutatedSubjectIntoSpecs
      @@project_path = nil
      @@require_expanders = [] of Array(InjectMutatedSubjectIntoSpecs)
    end

    class_getter already_parsed_file_name = Set(String).new
    class_getter file_list = [] of InjectMutatedSubjectIntoSpecs
    class_getter require_expanders = [] of Array(InjectMutatedSubjectIntoSpecs)
    class_getter! project_path : String

    getter! astree : Crystal::ASTNode
    getter! enriched_source : String

    getter path : String
    getter source : String

    def self.register_file(file)
      @@already_parsed_file_name.add(file.path)
      @@file_list << file
    end

    def self.relative_path_to_project(path)
      @@project_path ||= FileUtils.pwd
      path.gsub(/^#{InjectMutatedSubjectIntoSpecs.project_path}\//, "")
    end

    def self.parse_file(file)
      unless already_parsed_file_name.includes?(relative_path_to_project(file))
        already_parsed_file_name.add(relative_path_to_project(file))
        yield
      end
    end

    def initialize(@path, @source, @subject_path : String, @mutated_subject_source : String)
      @path = InjectMutatedSubjectIntoSpecs.relative_path_to_project(File.expand_path(@path, "."))
      InjectMutatedSubjectIntoSpecs.register_file(self)
    end

    # Inject in AST tree if required.
    def process
      unless @astree
        @astree = Crystal::Parser.parse(source)
        astree.accept(self)
      end
    end

    def to_mutated_source
      if @enriched_source.nil?
        # call process to enrich AST before
        # injection of cover head dependencies
        process

        @enriched_source = unfold_required(astree.to_s)
      else
        @enriched_source.not_nil!
      end
    end

    private def unfold_required(output)
      output.gsub(/require[ \t]+\"\$([0-9]+)\"/) do |_str, matcher|
        expansion_id = matcher[1].to_i
        file_list = InjectMutatedSubjectIntoSpecs.require_expanders[expansion_id]

        if file_list.any?
          String.build do |io|
            file_list.each do |file|
              io << "#" << " require of `" << file.path
              io << "` from `" << self.path << "`" << "\n"
              io << file.to_mutated_source
            end
          end
        else
          ""
        end
      end
    end

    # Management of required file is nasty and should be improved
    # Since I've hard time to replace node on visit,
    # I change the file argument to a number linked to an array of files
    # Then on finalization, we replace each require "xxx" by the proper file.
    def visit(node : Crystal::Require)
      file = node.string
      return false unless file.starts_with?(".")

      current_directory = InjectMutatedSubjectIntoSpecs.relative_path_to_project(File.dirname(@path))
      new_files_to_load = find_in_path_relative_to_dir(file, current_directory)

      return if new_files_to_load.nil?
      new_files_to_load = [new_files_to_load] if new_files_to_load.is_a?(String)

      idx = InjectMutatedSubjectIntoSpecs.require_expanders.size
      list_of_required_file = [] of InjectMutatedSubjectIntoSpecs
      InjectMutatedSubjectIntoSpecs.require_expanders << list_of_required_file

      new_files_to_load.each do |file_to_load|
        InjectMutatedSubjectIntoSpecs.parse_file(file_to_load) do
          required_file = InjectMutatedSubjectIntoSpecs.new(
            path: file_to_load,
            source: fetch_source(file_to_load),
            mutated_subject_source: @mutated_subject_source,
            subject_path: @subject_path)

          required_file.process # Process on load, since it can change the requirement order

          list_of_required_file << required_file
        end
      end

      node.string = "$#{idx}"

      false
    end

    def visit(node : Crystal::ASTNode)
      true
    end

    private def fetch_source(some_path : String)
      if some_path == File.expand_path(InjectMutatedSubjectIntoSpecs.relative_path_to_project(@subject_path))
        @mutated_subject_source
      else
        File.read(some_path)
      end
    end

    # All of the below code is stolen from crystal itself
    # https://github.com/crystal-lang/crystal/blob/master/src/compiler/crystal/crystal_path.cr
    # Because we are caring about relative requires "./foo/bar" exclusively, a lot of code
    # was removed from this method.
    private def find_in_path_relative_to_dir(filename, relative_to) : Array(String) | String | Nil
      # Check if it's a wildcard.
      recursive = filename.ends_with?("/**")

      if filename.ends_with?("/*") || recursive
        filename_dir_index = filename.rindex('/').not_nil!
        filename_dir = filename[0..filename_dir_index]
        relative_dir = "#{relative_to}/#{filename_dir}"

        if File.exists?(relative_dir)
          files = [] of String
          gather_dir_files(relative_dir, files, recursive)
          return files
        end
      else
        relative_filename = "#{relative_to}/#{filename}"

        # Check if .cr file exists.
        relative_filename_cr = relative_filename.ends_with?(".cr") ?
          relative_filename : "#{relative_filename}.cr"

        if File.exists?(relative_filename_cr)
          return make_relative_unless_absolute relative_filename_cr
        end
      end

      nil
    end

    private def gather_dir_files(dir, files_accumulator, recursive)
      files = [] of String
      dirs = [] of String

      Dir.each_child(dir) do |filename|
        full_name = "#{dir}/#{filename}"

        if File.directory?(full_name)
          if recursive
            dirs << filename
          end
        else
          if filename.ends_with?(".cr")
            files << full_name
          end
        end
      end

      files.sort!
      dirs.sort!

      files.each do |file|
        files_accumulator << File.expand_path(file)
      end

      dirs.each do |subdir|
        gather_dir_files("#{dir}/#{subdir}", files_accumulator, recursive)
      end
    end

    private def make_relative_unless_absolute(filename)
      filename = "#{Dir.current}/#{filename}" unless filename.starts_with?('/')
      File.expand_path(filename)
    end
  end
end
