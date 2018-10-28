require "../mutant/mutant"

module Crytic::Mutation
  enum Status
    Covered
    Error
    Timeout
    Uncovered

    def uncovered?
      self == Uncovered
    end

    def errored?
      self == Error
    end

    def covered?
      self == Covered
    end

    def timeout?
      self == Timeout
    end
  end

  record Result, status : Status, mutant : Mutant::Mutant, diff : String do
    def mutant_name
      mutant.class.to_s.split("::").last
    end

    def location
      mutant.location
    end
  end
end
