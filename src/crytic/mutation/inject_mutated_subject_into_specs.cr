require "compiler/crystal/syntax/*"
require "digest"
require "file_utils"

module Crytic
  class InjectMutatedSubjectIntoSpecs < Crystal::Visitor
    STR_CAPACITY = 2 ** 20

    def self.reset
      @@already_covered_file_name = Set(String).new
      @@file_list = [] of InjectMutatedSubjectIntoSpecs
      @@project_path = nil
      @@require_expanders = [] of Array(InjectMutatedSubjectIntoSpecs)
    end

    class_getter file_list = [] of InjectMutatedSubjectIntoSpecs
    class_getter already_covered_file_name = Set(String).new
    class_getter! project_path : String
    class_getter require_expanders = [] of Array(InjectMutatedSubjectIntoSpecs)

    class_property outputter : String = "Coverage::Outputter::HtmlReport"
    class_property use_require : String = "coverage/runtime"

    getter! astree : Crystal::ASTNode
    getter id : Int32 = 0
    getter path : String
    getter md5_signature : String

    getter lines = [] of Int32
    getter already_covered_locations = Set(Crystal::Location?).new

    getter source : String
    getter! enriched_source : String
    getter required_at : Int32

    def self.register_file(f)
      @@already_covered_file_name.add(f.path)
      @@file_list << f
      @@file_list.size - 1
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

    def initialize(@path, @source, @subject_path : String, @mutated_subject_source : String, @required_at = 0)
      @path = InjectMutatedSubjectIntoSpecs.relative_path_to_project(File.expand_path(@path, "."))
      @md5_signature = Digest::MD5.hexdigest(@source)
      @id = InjectMutatedSubjectIntoSpecs.register_file(self)
    end

    # Inject in AST tree if required.
    def process
      unless @astree
        @astree = Crystal::Parser.parse(self.source)
        astree.accept(self)
      end
    end

    def to_covered_source
      if @enriched_source.nil?
        io = String::Builder.new(capacity: 32_768)

        # call process to enrich AST before
        # injection of cover head dependencies
        process

        # Inject the location of the zero line of current file
        io << unfold_required(astree.to_s)

        @enriched_source = io.to_s
      else
        @enriched_source.not_nil!
      end
    end

    private def unfold_required(output)
      output.gsub(/require[ \t]+\"\$([0-9]+)\"/) do |_str, matcher|
        expansion_id = matcher[1].to_i
        file_list = @@require_expanders[expansion_id]

        if file_list.any?
          io = String::Builder.new(capacity: STR_CAPACITY)
          file_list.each do |file|
            io << "#" << " require of `" << file.path
            io << "` from `" << self.path << ":#{file.required_at}" << "`" << "\n"
            io << file.to_covered_source
          end
          io.to_s
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
      # we cover only files which are relative to current file
      if file[0] == '.'
        current_directory = InjectMutatedSubjectIntoSpecs.relative_path_to_project(File.dirname(@path))

        files_to_load = File.expand_path(file, current_directory)

        if files_to_load =~ /\*$/
          # Case when we want to require a directory and subdirectories
          if files_to_load.size > 1 && files_to_load[-2..-1] == "**"
            files_to_load += "/*.cr"
          else
            files_to_load += ".cr"
          end
        elsif files_to_load !~ /\.cr$/
          files_to_load = files_to_load + ".cr" # << Add the extension for the crystal file.
        end

        idx = InjectMutatedSubjectIntoSpecs.require_expanders.size
        list_of_required_file = [] of InjectMutatedSubjectIntoSpecs
        InjectMutatedSubjectIntoSpecs.require_expanders << list_of_required_file

        Dir[files_to_load].sort.each do |file_load|
          next if file_load !~ /\.cr$/

          InjectMutatedSubjectIntoSpecs.cover_file(file_load) do
            line_number = node.location.not_nil!.line_number

            if file_load == File.expand_path(InjectMutatedSubjectIntoSpecs.relative_path_to_project(@subject_path))
              the_source = @mutated_subject_source
            else
              the_source = File.read(file_load)
            end

            required_file = InjectMutatedSubjectIntoSpecs.new(
              path: file_load,
              source: the_source,
              mutated_subject_source: @mutated_subject_source,
              subject_path: @subject_path,
              required_at: line_number)

            required_file.process # Process on load, since it can change the requirement order

            list_of_required_file << required_file
          end
        end

        node.string = "$#{idx}"
      end

      false
    end

    def visit(node : Crystal::ASTNode)
      true
    end
  end
end
