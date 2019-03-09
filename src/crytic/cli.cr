require "./runner/sequential"
require "./subject"

module Crytic
  class Cli
    def initialize(@runner : Runner::Sequential)
    end

    def run
      @runner.run([] of Subject, [] of String)
    end
  end
end
