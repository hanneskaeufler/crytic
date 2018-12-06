module Crytic
  abstract class Generator
    abstract def mutations_for(source : String, specs : Array(String))
  end
end
