require "./blog"
require "spec"

describe Blog do
  it "renders" do
    Blog.new.render.should eq "welcome page 1"
  end
end
