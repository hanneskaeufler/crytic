require "spec"
require "../src/crytic/runner"

describe Crytic::Runner do
  describe "#run" do
    it "raises for empty specs" do
      expect_raises(ArgumentError) do
        Crytic::Runner.new.run("", [] of String)
      end
    end

    it "raises for non-existent files" do
      expect_raises(ArgumentError) do
        Crytic::Runner.new.run("./nope.cr", ["./nope_spec.cr"])
      end
      expect_raises(ArgumentError) do
        Crytic::Runner.new.run("./fixtures/simple/bar.cr", ["./nope_spec.cr"])
      end
    end
  end
end
