require "../src/crytic/mutation/original_result"

class FakeRun
  property mutations = [] of Crytic::Mutation::Mutation
  property neutral = FakeMutation.new.as(Crytic::Mutation::Mutation)
  property events = [] of String
  property original_exit_code = 0
  property original_call_count = 0
  property generate_mutations_call_count = 0
  property final_result = true

  def generate_mutations
    @generate_mutations_call_count += 1
    [Crytic::Generator::MutationSet.new(neutral, mutations)]
  end

  def report_neutral_result(result)
    events << "report_neutral_result"
  end

  def report_result(result)
    events << "report_result"
  end

  def report_final(results)
    final_result
  end

  def execute_original_test_suite(side_effects)
    @original_call_count += 1
    Crytic::Mutation::OriginalResult.new(exit_code: original_exit_code, output: "")
  end
end
