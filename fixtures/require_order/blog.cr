require "./pages/**"

class Blog
  def render
    "#{Archive.new.render} #{1}"
  end
end
