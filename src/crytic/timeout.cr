module Crytic
  class Timeout
    def self.after_select_action(seconds)
      ch = Channel(Nil).new
      spawn do
        sleep seconds
        ch.send nil
      end
      ch.receive_select_action
    end
  end
end
