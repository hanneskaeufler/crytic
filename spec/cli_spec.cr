require "../src/crytic/cli"
require "../src/crytic/reporter/reporter"
require "../src/crytic/runner/sequential"
require "../src/crytic/subject"
require "./fake_generator"
require "./spec_helper"

module Crytic
  describe Cli do
    describe "#run" do
      it "invokes the runner" do
        runner = FakeRunner.new

        success = Cli.new(runner).run

        success.should eq true
        runner.call_count.should eq 1
      end
    end
  end
end

class FakeRunner < Crytic::Runner::Sequential
  getter call_count
  @call_count = 0

  def initialize
    @threshold = 0.0
    @reporters = [] of Crytic::Reporter::Reporter
    @generator = FakeGenerator.new
    @no_mutation_factory = fake_no_mutation_factory
    @call_count = 0
  end

  def run(subjects : Array(Crytic::Subject), specs : Array(String)) : Bool
    @call_count += 1
    true
  end
end
