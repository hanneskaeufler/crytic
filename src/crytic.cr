require "option_parser"
require "./crytic/runner"

subject_source = ""
spec_files = [] of String

OptionParser.parse! do |parser|
  parser.banner = "Usage: crytic [arguments]"
  parser.on("-s SOURCE", "--subject=SOURCE", "Specifies the source file for the subject") do |source|
    subject_source = source
  end
  parser.on("-h", "--help", "Show this help") { puts parser }
  parser.unknown_args do |args|
    spec_files = args
  end
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

io = IO::Memory.new
success = Crytic::Runner.new(io).run(subject_source, spec_files)
puts io.to_s

exit(success ? 0 : 1)
