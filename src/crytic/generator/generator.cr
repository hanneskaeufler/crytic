module Crytic
  abstract class Generator
    abstract def mutations_for(source : Array(String), specs : Array(String))
  end
end
