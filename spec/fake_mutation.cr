require "../../src/crytic/mutant/bool_literal_flip"
require "../../src/crytic/mutation/mutation"
require "../../src/crytic/mutation/result"

private def irrelevant_mutant
  Crytic::Mutant::BoolLiteralFlip.at(Crytic::Mutant::FullLocation.new(Crystal::Location.new(
    filename: nil,
    line_number: 2,
    column_number: 6,
  )))
end

class FakeMutation < Crytic::Mutation::MutationInterface
  property run_call_count = 0

  def initialize(@reported_status = Crytic::Mutation::Status::Uncovered)
  end

  def run
    @run_call_count += 1
    Crytic::Mutation::Result.new(@reported_status, irrelevant_mutant, "")
  end
end
