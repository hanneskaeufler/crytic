module Crytic::Mutation
  class RequireResolver
    # All of the below code is stolen from crystal itself
    # https://github.com/crystal-lang/crystal/blob/master/src/compiler/crystal/crystal_path.cr
    # Because we are caring about relative requires "./foo/bar" exclusively, a lot of code
    # was removed from this method.
    def find_in_path_relative_to_dir(filename, relative_to) : Array(String) | Nil
      # Check if it's a wildcard.
      recursive = filename.ends_with?("/**")

      if filename.ends_with?("/*") || recursive
        filename_dir_index = filename.rindex!('/')
        filename_dir = filename[0..filename_dir_index]
        relative_dir = "#{relative_to}/#{filename_dir}"

        if File.exists?(relative_dir)
          files = [] of String
          gather_dir_files(relative_dir, files, recursive)
          return files
        end
      else
        relative_filename = "#{relative_to}/#{filename}"

        # Check if .cr file exists.
        relative_filename_cr = relative_filename.ends_with?(".cr") ? relative_filename : "#{relative_filename}.cr"

        if File.exists?(relative_filename_cr)
          return [make_relative_unless_absolute relative_filename_cr]
        end

        # If it's "foo/bar/baz", check if "foo/bar/baz/baz.cr" exists (std, nested)
        basename = File.basename(relative_filename)
        absolute_filename = make_relative_unless_absolute("#{relative_to}/#{filename}/#{basename}.cr")
        return [absolute_filename] if File.exists?(absolute_filename)
      end

      nil
    end

    private def gather_dir_files(dir, files_accumulator, recursive)
      files = [] of String
      dirs = [] of String

      Dir.each_child(dir) do |filename|
        full_name = "#{dir}/#{filename}"

        if File.directory?(full_name)
          if recursive
            dirs << filename
          end
        else
          if filename.ends_with?(".cr")
            files << full_name
          end
        end
      end

      files.sort!
      dirs.sort!

      files.each do |file|
        files_accumulator << File.expand_path(file)
      end

      dirs.each do |subdir|
        gather_dir_files("#{dir}/#{subdir}", files_accumulator, recursive)
      end
    end

    private def make_relative_unless_absolute(filename)
      filename = "#{Dir.current}/#{filename}" unless filename.starts_with?('/')
      File.expand_path(filename)
    end
  end
end
