require "../mutant/mutant"

module Crytic::Mutation
  enum Status
    Covered
    Errored
    Timeout
    Uncovered
  end

  record Result, status : Status, mutant : Mutant::Mutant, diff : String do
    delegate uncovered?, covered?, errored?, timeout?, to: status

    def mutant_name
      mutant.class.to_s.split("::").last
    end

    def location : Crystal::Location
      mutant.location.location
    end

    def mutated_file : String
      location.filename.to_s || ""
    end
  end

  class ResultSet
    delegate size, empty?, to: @results

    def initialize(@results = [] of Result)
    end

    {% for status in [:covered, :uncovered, :errored, :timeout] %}
      def {{ status.id }}_count
        @results.count(&.{{ status.id }}?)
      end
    {% end %}

    def all_covered?
      @results.all?(&.covered?)
    end

    def grouped_by_mutated_file
      @results
        .group_by(&.mutated_file)
        .transform_values { |by_filename| ResultSet.new(by_filename) }
    end

    def longest_mutated_filename_length
      @results.map(&.mutated_file.size).max? || 0
    end
  end
end
