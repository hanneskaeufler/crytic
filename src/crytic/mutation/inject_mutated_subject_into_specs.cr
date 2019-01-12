require "compiler/crystal/syntax/*"
require "digest"
require "file_utils"

module Crytic::Mutation
  class ArbitrarySourceCodeFile
    def initialize(@path : String, @mutated_subject_source : String, @subject_path : String)
    end

    def source
      if @path == relative_path
        @mutated_subject_source
      else
        File.read(@path)
      end
    end

    private def relative_path
      File.expand_path(InjectMutatedSubjectIntoSpecs.relative_path_to_project(@subject_path))
    end
  end

  class InjectMutatedSubjectIntoSpecs < Crystal::Visitor

    # Because the class is used and instantiated multiple times, but these are
    # class vars, they need to be resetted :(
    def self.reset
      @@already_covered_file_name = Set(String).new
      @@file_list = [] of InjectMutatedSubjectIntoSpecs
      @@project_path = nil
      @@require_expanders = [] of Array(InjectMutatedSubjectIntoSpecs)
    end

    class_getter already_covered_file_name = Set(String).new
    class_getter file_list = [] of InjectMutatedSubjectIntoSpecs
    class_getter require_expanders = [] of Array(InjectMutatedSubjectIntoSpecs)
    class_getter! project_path : String

    getter! astree : Crystal::ASTNode
    getter! enriched_source : String

    getter path : String
    getter source : String

    def self.register_file(file)
      @@already_covered_file_name.add(file.path)
      @@file_list << file
    end

    def self.relative_path_to_project(path)
      @@project_path ||= FileUtils.pwd
      path.gsub(/^#{InjectMutatedSubjectIntoSpecs.project_path}\//, "")
    end

    def self.cover_file(file)
      unless already_covered_file_name.includes?(relative_path_to_project(file))
        already_covered_file_name.add(relative_path_to_project(file))
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

    def to_covered_source
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
              io << file.to_covered_source
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
      return false unless file[0] == '.'

      current_directory = InjectMutatedSubjectIntoSpecs.relative_path_to_project(File.dirname(@path))
      new_files_to_load = find_in_path_relative_to_dir(file, current_directory)

      return if new_files_to_load.nil?
      new_files_to_load = [new_files_to_load] if new_files_to_load.is_a?(String)

      idx = InjectMutatedSubjectIntoSpecs.require_expanders.size
      list_of_required_file = [] of InjectMutatedSubjectIntoSpecs
      InjectMutatedSubjectIntoSpecs.require_expanders << list_of_required_file

      new_files_to_load.each do |file_to_load|
        next if file_to_load !~ /\.cr$/

        InjectMutatedSubjectIntoSpecs.cover_file(file_to_load) do
          the_source = ArbitrarySourceCodeFile.new(
            file_to_load,
            @mutated_subject_source,
            @subject_path
          ).source

          required_file = InjectMutatedSubjectIntoSpecs.new(
            path: file_to_load,
            source: the_source,
            mutated_subject_source: @mutated_subject_source,
            subject_path: @subject_path)

          required_file.process # Process on load, since it can change the requirement order

          list_of_required_file << required_file
        end

        node.string = "$#{idx}"
      end

      false
    end

    def visit(node : Crystal::ASTNode)
      true
    end

    # All of the below code is stolen from crystal itself
    # https://github.com/crystal-lang/crystal/blob/master/src/compiler/crystal/crystal_path.cr
    private def find_in_path_relative_to_dir(filename, relative_to)
      if relative_to.is_a?(String)
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
          relative_filename_cr = relative_filename.ends_with?(".cr") ? relative_filename : "#{relative_filename}.cr"
          if File.exists?(relative_filename_cr)
            return make_relative_unless_absolute relative_filename_cr
          end

          if filename.index('/')
            # If it's "foo/bar/baz", check if "foo/src/bar/baz.cr" exists (for a shard, non-namespaced structure)
            before_slash, after_slash = filename.split('/', 2)
            absolute_filename = make_relative_unless_absolute("#{relative_to}/#{before_slash}/src/#{after_slash}.cr")
            return absolute_filename if File.exists?(absolute_filename)

            # Then check if "foo/src/foo/bar/baz.cr" exists (for a shard, namespaced structure)
            absolute_filename = make_relative_unless_absolute("#{relative_to}/#{before_slash}/src/#{before_slash}/#{after_slash}.cr")
            return absolute_filename if File.exists?(absolute_filename)

            # If it's "foo/bar/baz", check if "foo/bar/baz/baz.cr" exists (std, nested)
            basename = File.basename(relative_filename)
            absolute_filename = make_relative_unless_absolute("#{relative_to}/#{filename}/#{basename}.cr")
            return absolute_filename if File.exists?(absolute_filename)

            # If it's "foo/bar/baz", check if "foo/src/foo/bar/baz/baz.cr" exists (shard, non-namespaced, nested)
            absolute_filename = make_relative_unless_absolute("#{relative_to}/#{before_slash}/src/#{after_slash}/#{after_slash}.cr")
            return absolute_filename if File.exists?(absolute_filename)

            # If it's "foo/bar/baz", check if "foo/src/foo/bar/baz/baz.cr" exists (shard, namespaced, nested)
            absolute_filename = make_relative_unless_absolute("#{relative_to}/#{before_slash}/src/#{before_slash}/#{after_slash}/#{after_slash}.cr")
            return absolute_filename if File.exists?(absolute_filename)
          else
            basename = File.basename(relative_filename)

            # If it's "foo", check if "foo/foo.cr" exists (for the std, nested)
            absolute_filename = make_relative_unless_absolute("#{relative_filename}/#{basename}.cr")
            return absolute_filename if File.exists?(absolute_filename)

            # If it's "foo", check if "foo/src/foo.cr" exists (for a shard)
            absolute_filename = make_relative_unless_absolute("#{relative_filename}/src/#{basename}.cr")
            return absolute_filename if File.exists?(absolute_filename)
          end
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
