module Crytic
  class Runner
    def call(args)
      output = IO::Memory.new
      error = IO::Memory.new
      mutations = ["dsa"] of String
      results = [] of Bool
      mutations.each do
        result = Process.run("crystal spec #{args.first}", output: output, error: error)
        puts output
        results << result.success?
      end
      puts "Ran tests against #{mutations.size} mutations. #{results.all? ? "Passed" : "Failed"}."
      results.all?
    end
  end
end

