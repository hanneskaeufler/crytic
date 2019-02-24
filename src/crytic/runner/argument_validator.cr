module Crytic::Runner
  module ArgumentValidator
    private def validate_args!(source, specs)
      subjects = source.map do |path|
        unless File.exists?(path)
          raise ArgumentError.new("Source file for subject #{path} doesn't exist.")
        end
        Subject.from_filepath(path)
      end

      specs.each do |spec_file|
        unless File.exists?(spec_file)
          raise ArgumentError.new("Spec file #{spec_file} doesn't exist.")
        end
      end

      subjects
    end
  end
end
