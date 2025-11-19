require "./config"
require "../side_effects"

module Crytic::Mutation
  record Environment,
    config : Config,
    side_effects : Crytic::SideEffects do
    delegate :subject, :mutant, :preamble, to: config
    delegate :remove_file, :write_tempfile, :execute, to: side_effects

    def perform_mutation
      subject.mutated(mutant)
    end

    def subject_path
      subject.path
    end

    def spec_file_paths
      config.specs
    end
  end
end
