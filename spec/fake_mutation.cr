require "../../src/crytic/mutant/bool_literal_flip"
require "../../src/crytic/mutation/mutation"
require "../../src/crytic/mutation/result"

private def irrelevant_mutant
  Crytic::Mutant::BoolLiteralFlip.at(Crystal::Location.new(
    filename: nil,
    line_number: 2,
    column_number: 6,
  ))
end

class FakeMutation
  property run_call_count = 0

  def run
    @run_call_count += 1
    Crytic::Mutation::Result.new(Crytic::Mutation::Status::Uncovered, irrelevant_mutant, "")
  end
end
