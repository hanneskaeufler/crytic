require "../../src/crytic/runner/run"
require "../spec_helper"

describe Crytic::Runner::Run do
  it "is just another wrapper for options" do
    opts = Opts.new(99.0, [] of Crytic::Reporter::Reporter, [] of String, [] of Crytic::Subject)

    Crytic::Runner::Run
      .from_options(opts, FakeGenerator.new, fake_no_mutation_factory)
      .msi_threshold.should eq 99.0
  end
end

# Must have the same implicit interface as CliOptions
private record Opts,
  msi_threshold : Float64,
  reporters : Crytic::Reporter::Reporters,
  spec_files : Array(String),
  subject : Array(Crytic::Subject) do
end
