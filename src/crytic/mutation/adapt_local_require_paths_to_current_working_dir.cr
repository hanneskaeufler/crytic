require "compiler/crystal/syntax/*"

module Crytic
  class AdaptLocalRequirePathsToCurrentWorkingDir < Crystal::Visitor
    def initialize(@subject_file_path : String, @spec_path : String)
    end

    def visit(node : Crystal::Require)
      # only care for locally required files, not modules / shards
      return true unless node.string[0..1] == "./"

      if required_file(node) == @subject_file_path
        node.string = @subject_file_path
      end

      true
    end

    # Ignore other nodes for now
    def visit(node : Crystal::ASTNode)
      true
    end

    private def required_file(node)
      "#{File.dirname(@spec_path)}/#{node.string.[2..-1]}.cr"
    end
  end
end
