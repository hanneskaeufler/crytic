require "./inject_mutated_subject_into_specs"
require "file_utils"

module Crytic::Mutation
  class Tracker
    private property already_parsed_file_name = Set(String).new
    private property require_expanders = [] of Array(InjectMutatedSubjectIntoSpecs)

    def required_files_for_id(expansion_id)
      require_expanders[expansion_id]
    end

    def currently_tracked_count
      require_expanders.size
    end

    def new_bag
      list_of_required_file = [] of InjectMutatedSubjectIntoSpecs
      require_expanders << list_of_required_file
      list_of_required_file
    end

    def register_file(file)
      already_parsed_file_name.add(file.path)
      relative_path_to_project(File.expand_path(file.path, "."))
    end

    def already_tracked?(file)
      already_parsed_file_name.includes?(file)
    end

    def parse_file_at_path(file)
      file = relative_path_to_project(file)
      unless already_tracked?(file)
        already_parsed_file_name.add(file)
        yield
      end
    end

    private def relative_path_to_project(path)
      path.gsub(/^#{FileUtils.pwd}\//, "")
    end
  end
end
