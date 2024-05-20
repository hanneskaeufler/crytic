# ameba:disable Lint/SpecFilename
class FakeFile
  @@files_deleted = [] of String
  @@tempfiles_created = [] of String
  @@tempfile_contents = [] of String

  def self.tempfile_contents
    @@tempfile_contents
  end

  def self.delete(filename : String)
  end

  def self.tempfile(name, extension, content) : String
    filename = "#{name}.RANDOM#{extension}"
    @@tempfile_contents << content
    @@tempfiles_created << filename
    "/tmp/#{filename}"
  end
end
