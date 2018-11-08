require "./with_fixture"
require "spec"

describe WithFixture do
  describe ".read" do
    it "returns the content" do
      WithFixture.read(__DIR__ + "/foobar.txt").should eq "hello world\n"
    end
  end
end
