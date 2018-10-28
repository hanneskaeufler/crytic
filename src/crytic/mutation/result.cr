require "../mutant/mutant"

module Crytic::Mutation
  enum Status
    Covered
    Errored
    Timeout
    Uncovered

    {% for method in ["Uncovered", "Errored", "Covered", "Timeout"] %}
      def {{ method.downcase.id }}?
        self == {{ method.id }}
      end
    {% end %}
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
