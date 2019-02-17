require "../mutation/isolated_mutation"

module Crytic::Generator
  extend self

  def isolated_mutation_factory(config)
    Mutation::IsolatedMutation.with(
      Mutation::Environment.new(
        config,
        ProcessProcessRunner.new,
        ->File.delete(String),
        ->(name : String, extension : String, content : String) {
          File.tempfile(name, extension) { |file| file.print(content) }.path
        })).as(Mutation::Mutation)
  end
end
