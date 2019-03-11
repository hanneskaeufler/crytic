class Crytic::SideEffects
  getter std_out : IO
  getter std_err : IO
  getter exit_fun : (Int32) ->
  getter env : Hash(String, String)

  def initialize(@std_out, @std_err, @exit_fun, @env)
  end
end
