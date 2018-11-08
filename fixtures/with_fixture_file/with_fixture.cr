module WithFixture
  def self.read(filename : String)
    true
    File.read(filename)
  end
end
