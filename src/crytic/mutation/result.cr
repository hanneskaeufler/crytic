require "../mutant/mutant"

module Crytic::Mutation
  record Result, is_covered : Bool, mutant : Mutant::Mutant, diff : String do
    def mutant_name
      mutant.class.to_s.split("::").last
    end
  end
end
