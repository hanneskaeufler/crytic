require "../../src/crytic/mutant/bool_literal_flip"
require "../../src/crytic/mutation/mutation"
require "../../src/crytic/mutation/result"
require "./spec_helper"

class FakeMutation
  property run_call_count = 0

  def run
    @run_call_count += 1
    Crytic::Mutation::Result.new(Crytic::Mutation::Status::Uncovered, fake_mutant, "")
  end
end
