require "compiler/crystal/syntax/*"
require "spec"
require "../../src/crytic/mutation/adapt_local_require_paths_to_current_working_dir"

module Crytic
  describe AdaptLocalRequirePathsToCurrentWorkingDir do
    it "leaves module includes alone but fixes relative paths" do
      spec = "./spec/foo_spec.cr"
      spec_code = <<-CODE
      require "diff"
      require "./spec_helper"
      CODE
      ast = Crystal::Parser.parse(spec_code)
      ast.accept(AdaptLocalRequirePathsToCurrentWorkingDir.new("", spec))
      ast.to_s.should eq <<-CODE
      require "diff"
      require "./spec/spec_helper.src"
      CODE
    end
  end
end
