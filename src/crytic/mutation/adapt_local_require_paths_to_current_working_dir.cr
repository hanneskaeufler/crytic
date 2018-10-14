require "compiler/crystal/syntax/*"

module Crytic
  class AdaptLocalRequirePathsToCurrentWorkingDir < Crystal::Visitor
    def initialize(@subject_file_path : String, @spec_path : String)
    end

    def visit(node : Crystal::Require)
      # only care for locally required files, not modules / shards
      return true unless node.string[0..1] == "./"

      node.string = "#{File.dirname(@spec_path)}/#{node.string[2..-1]}"
      true
    end

    def visit(node : Crystal::ASTNode)
      true
    end
  end
end
