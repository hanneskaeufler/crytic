require "../reporter/reporter"
require "../subject"

module Crytic::Runner
  record Run, msi_threshold : Float64, reporters : Array(Crytic::Reporter::Reporter), spec_files : Array(String), subject : Array(Subject) do
    def self.from_options(options)
      new(options.msi_threshold, options.reporters, options.spec_files, options.subject)
    end
  end
end
