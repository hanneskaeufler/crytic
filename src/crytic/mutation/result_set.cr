module Crytic::Mutation
  class ResultSet
    delegate empty?, to: @results

    def total_count
      @results.size
    end

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
      @results.max_of?(&.mutated_file.size) || 0
    end
  end
end
