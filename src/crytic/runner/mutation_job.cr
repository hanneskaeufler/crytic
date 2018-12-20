require "dispatch"

module Crytic
  module Runner
    class MutationJob
      include Dispatchable

      def perform(mutation, reporters, results)
        result = mutation.run
        reporters.each(&.report_result(result))
        results << result
      end
    end
  end
end
