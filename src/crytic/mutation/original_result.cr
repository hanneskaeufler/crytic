module Crytic::Mutation
  record OriginalResult, exit_code : Int32, output : String do
    def successful?
      exit_code == 0
    end
  end
end
