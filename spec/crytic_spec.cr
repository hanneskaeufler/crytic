require "../src/crytic/version.cr"
require "./spec_helper.cr"

describe Crytic do
  it "has matching version strings" do
    module_version = Crytic::VERSION

    shard_version.should eq module_version
    readme_version.should eq module_version
    docs_version.should eq module_version
    changelog_version.should eq module_version
  end
end

private def shard_version
  File.read("shard.yml").lines[1].strip("version: ~>")
end

private def readme_version
  /version: ~> (.*)/.match(File.read("README.md")).try &.[1]
end

private def docs_version
  /&quot;(\d\.\d\.\d)&quot;/.match(File.read("docs/api/Crytic.html")).try &.[1]
end

private def changelog_version
  /## \[(\d\.\d\.\d)\]/.match(File.read("CHANGELOG.md")).try &.[1]
end
