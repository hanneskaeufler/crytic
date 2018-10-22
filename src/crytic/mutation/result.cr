require "../mutant/mutant"

module Crytic::Mutation
  record Result, is_covered : Bool, did_error : Bool, mutant : Mutant::Mutant, diff : String do
    def mutant_name
      mutant.class.to_s.split("::").last
    end

    def successful?
      is_covered && !did_error
    end

    def location
      mutant.location
    end
  end
end
