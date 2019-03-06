require "../../src/crytic/mutation/require_resolver"
require "../spec_helper"
require "file_utils"

module Crytic::Mutation
  describe RequireResolver do
    describe "#find_in_path_relative_to_dir" do
      it "resolves files in src/html/builder" do
        files = RequireResolver
          .new
          .find_in_path_relative_to_dir("./html/builder", "./fixtures/folder_require")

        files.should eq ["#{FileUtils.pwd}/fixtures/folder_require/html/builder/builder.cr"]
      end
    end
  end
end
