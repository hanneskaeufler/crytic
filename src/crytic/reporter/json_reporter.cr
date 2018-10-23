require "json"
require "../mutation/original_result"

module Crytic::Reporter
  class JsonReporter
    private getter! original
    @original : Mutation::OriginalResult?

    def report_original_result(result)
      @original = result
    end

    def to_json
      {
        original: {
          success: original.exit_code == 0,
          output:  original.output,
        },
      }.to_json
    end
  end
end
