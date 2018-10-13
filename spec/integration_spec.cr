require "spec"

describe "Crytic" do
  context "conditionals" do
    context "a source file without conditionals" do
      it "runs the spec once because there are no mutations to be done" do
        output = IO::Memory.new
        run_crytic_on(
          file: "conditionals/without_spec.cr",
          output: output
        ).exit_code.should_not be_unsuccessful
        output.to_s.should contain("Ran tests against 0 mutations. Passed.")
      end
    end

    context "a fully covered source file with conditionals" do
      it "passes, as there are no mutations that _didnt_ make the tests fail" do
        output = IO::Memory.new
        run_crytic_on(
          file: "conditionals/fully_covered_spec.cr",
          output: output
        ).exit_code.should_not be_unsuccessful
        output.to_s.should contain("Ran tests against 1 mutations. Passed.")
      end
    end

    context "an uncovered source file with conditionals" do
      it "fails, as the mutation did make the tests fail" do
        output = IO::Memory.new
        run_crytic_on(
          file: "conditionals/uncovered_spec.cr",
          output: output).exit_code.should be_unsuccessful
        output.to_s.should contain("Ran tests against 1 mutations. Failed.")
      end
    end
  end
end

def run_crytic_on(file, output)
  err = IO::Memory.new
  res = Process.run("crystal ../src/crytic.cr fixtures/#{file}", output: output, error: err)
  # puts err
  res
end

def be_unsuccessful
  be > 0
end
