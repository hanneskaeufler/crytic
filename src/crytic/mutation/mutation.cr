require "./result"

module Crytic::Mutation
  abstract class Mutation
    abstract def run : Result
  end
end
