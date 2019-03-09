module Crytic::Mutation
  class Tracker
    private property already_parsed_file_name = Set(String).new
    private property file_list = [] of InjectMutatedSubjectIntoSpecs
    property require_expanders = [] of Array(InjectMutatedSubjectIntoSpecs)

    def register_file(file)
      already_parsed_file_name.add(file.path)
      file_list << file
    end

    def track_file(file)
      already_parsed_file_name.add(file)
    end

    def already_tracked?(file)
      already_parsed_file_name.includes?(file)
    end

    def parse_file(file)
      unless already_tracked?(file)
        track_file(file)
        yield
      end
    end
  end

end
