module Crytic::Runner
  module ArgumentValidator
    private def validate_args!(subjects, specs)
      specs.each do |spec_file|
        unless File.exists?(spec_file)
          raise ArgumentError.new("Spec file #{spec_file} doesn't exist.")
        end
      end
    end
  end
end
