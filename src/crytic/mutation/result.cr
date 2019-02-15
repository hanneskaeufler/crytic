require "../mutant/mutant"

module Crytic::Mutation
  enum Status
    Covered
    Errored
    Timeout
    Uncovered
  end

  record Result,
    status : Status,
    mutant : Mutant::Mutant,
    diff : String,
    output : String do
    delegate uncovered?, covered?, errored?, timeout?, to: status

    def mutant_name
      mutant.class.to_s.split("::").last
    end

    def location : Crystal::Location
      mutant.location.location
    end

    def mutated_file : String
      location.filename.to_s
    end
  end
end
