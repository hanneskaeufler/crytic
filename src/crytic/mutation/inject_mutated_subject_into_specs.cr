require "./require_resolver"
require "./tracker"
require "compiler/crystal/syntax/*"

module Crytic::Mutation
  class InjectMutatedSubjectIntoSpecs < Crystal::Visitor
    getter! astree : Crystal::ASTNode
    getter! enriched_source : String
    getter path : String

    def initialize(
      @path,
      @source : String,
      @mutated_subject : MutatedSubject,
      @tracker : Tracker,
    )
      @path = @tracker.register_file(self)
    end

    # Inject in AST tree if required.
    def process
      unless @astree
        @astree = Crystal::Parser.parse(@source)
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
        # force unwrapping is fine here, we're in the else
        # branch of having done the nil check
        @enriched_source.not_nil! # ameba:disable Lint/NotNil
      end
    end

    private def unfold_required(output)
      output.gsub(/require\s+"\$(\d+)"/) do |_str, matcher|
        file_list = @tracker.required_files_for_id(matcher[1].to_i)

        String.build do |io|
          file_list.each do |file|
            io << "# require of `#{file.path}` from `#{self.path}`\n"
            io << file.to_mutated_source
          end
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

      new_files_to_load = RequireResolver
        .new
        .find_in_path_relative_to_dir(file, current_directory)

      return if new_files_to_load.nil?

      idx = @tracker.currently_tracked_count
      list_of_required_file = @tracker.new_bag

      new_files_to_load.each do |file_to_load|
        @tracker.parse_file_at_path(file_to_load) do
          required_file = InjectMutatedSubjectIntoSpecs.new(
            path: file_to_load,
            source: @mutated_subject.source_or_other_source(file_to_load),
            mutated_subject: @mutated_subject,
            tracker: @tracker)

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

    private def current_directory
      File.dirname(@path)
    end
  end
end
