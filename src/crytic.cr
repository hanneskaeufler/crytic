require "./crytic/runner"

source = <<-SOURCE
require "spec"

def bar
  if 1
    2
  else
    3
  end
end

describe "bar" do
  it "works" do
    bar.should eq 2
  end
end
SOURCE

exit(Crytic::Runner.new.run(source) ? 0 : 1)
