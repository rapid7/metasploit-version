#
# Gems
#


require 'thor'

#
# Project
#

require 'metasploit/version'
require 'metasploit/version/version'

# Command-line interface for `metasploit-version`.  Used to run commands for managing the semantic version of a project.
class Metasploit::Version::CLI < Thor
  #
  # CONSTANTS
  #

  # Name of this gem, for use in other projects that call `metasploit-version install`.
  GEM_NAME = 'metasploit-version'
  # Line added to a project's gemspec to add `metasploit-version` as a development dependency.
  #
  # @todo Change to '~> #{Metasploit::Version::Version::MAJOR}.#{Metasploit::Version::Version::MINOR}' once metasploit-version is 1.0.0
  DEVELOPMENT_DEPENDENCY_LINE = "  spec.add_development_dependency '#{GEM_NAME}', '~> #{Metasploit::Version::Version::MAJOR}.#{Metasploit::Version::Version::MINOR}.#{Metasploit::Version::Version::PATCH}'\n"
  # Matches pre-existing development dependency on metasploit-version for updating.
  DEVELOPMENT_DEPENDENCY_REGEXP = /spec\.add_development_dependency\s+(?<quote>"|')#{GEM_NAME}\k<quote>/

  #
  # Commands
  #

  desc 'install',
       "Adds 'metasploit-version' as a development dependency in this project's gemspec"
  # Adds 'metasploit-version' as a development dependency in this project's gemspec.
  #
  # @return [void]
  def install
    ensure_development_dependency
  end

  no_commands do
    def ensure_development_dependency
      path = gemspec_path
      gem_specification = Gem::Specification.load(path)

      metasploit_version = gem_specification.dependencies.find { |dependency|
        dependency.name == GEM_NAME
      }

      lines = []

      if metasploit_version
        if metasploit_version.requirements_list.include? '>= 0'
          shell.say "Adding #{GEM_NAME} as a development dependency to "
        else
          shell.say "Updating #{GEM_NAME} requirements in "
        end

        shell.say path

        File.open(path) do |f|
          f.each_line do |line|
            match = line.match(DEVELOPMENT_DEPENDENCY_REGEXP)

            if match
              lines << DEVELOPMENT_DEPENDENCY_LINE
            else
              lines << line
            end
          end
        end
      else
        end_index = nil
        lines = []

        open(path) do |f|
          line_index = 0

          f.each_line do |line|
            lines << line

            if line =~ /^\s*end\s*$/
              end_index = line_index
            end

            line_index += 1
          end
        end

        lines.insert(end_index, DEVELOPMENT_DEPENDENCY_LINE)
      end

      File.open(path, 'w') do |f|
        lines.each do |line|
          f.write(line)
        end
      end
    end

    def gemspec_path
      unless instance_variable_defined? :@gemspec
        paths = Dir['*.gemspec']
        path_count = paths.length

        if path_count < 1
          shell.say 'No gemspec found'
          exit 1
        elsif path_count > 1
          shell.say 'Too many gemspecs'
          exit 1
        end

        @gemspec_path = paths.first
      end

      @gemspec_path
    end
  end
end