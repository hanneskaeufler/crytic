require "../../src/crytic/reporter/timer"
require "../spec_helper.cr"

module Crytic::Reporter
  describe Timer do
    describe "#elapsed_time" do
      it "returns the time elapsed since the start time" do
        current_time = Time.utc(2016, 2, 15, 10, 20, 30)
        time = -> { current_time }
        timer = Timer.new(time)
        current_time = Time.utc(2016, 2, 15, 10, 21, 30)
        timer.elapsed_time.should eq 1.minute
      end
    end
  end
end
