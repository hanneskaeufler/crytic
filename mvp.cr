# subject = ARGV[1]
# path_to_test_suite = ARGV[2]

prelude = <<-PRELUDE
require "spec/dsl"

class NoOutputFormatter < Spec::Formatter
end

spec.override_default_formatter(NoOutputFormatter.new)

p "done"
PRELUDE

cmd = "echo #{prelude.strip} | crystal eval"
system(cmd)
# process = Process.run("echo hello", output: STDIN, error: STDERR)
# puts process.success?
