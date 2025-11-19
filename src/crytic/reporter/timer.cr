module Crytic::Reporter
  class Timer
    @start_time : Time

    def initialize(@time : -> Time = -> { Time.utc })
      @start_time = @time.call
    end

    def elapsed_time : Time::Span
      @time.call - @start_time
    end
  end
end
