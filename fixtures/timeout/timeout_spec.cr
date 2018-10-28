require "./timeout"
require "spec"

describe "#timeout" do
  it "returns nil" do
    timeout.should be_nil
  end
end
