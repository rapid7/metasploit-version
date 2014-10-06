#
# Standard library
#

require 'pathname'

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
  include Thor::Actions

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
  # Class options
  #

  class_option :force,
               default: false,
               desc: 'Force overwriting conflicting files',
               type: :boolean
  class_option :skip,
               default: false,
               desc: 'Skip conflicting files',
               type: :boolean

  #
  # Configuration
  #

  root = Pathname.new(__FILE__).parent.parent.parent.parent
  source_root root.join('app', 'templates')

  #
  # Commands
  #

  desc 'install',
       "Install metasploit-version and sets up files"
  long_desc(
      "Adds 'metasploit-version' as a development dependency in this project's gemspec OR updates the semantic version requirement; " \
      "adds semantic versioning version.rb file."
  )
  option :major,
         banner: 'MAJOR',
         default: 0,
         desc: 'Major version number',
         type: :numeric
  option :minor,
         banner: 'MINOR',
         default: 0,
         desc: 'Minor version number, scoped to MAJOR version number.',
         type: :numeric
  option :patch,
         banner: 'PATCH',
         default: 1,
         desc: 'Patch version number, scoped to MAJOR and MINOR version numbers.',
         type: :numeric
  option :bundle_install,
         default: true,
         desc: '`bundle install` after adding `metasploit-version` as a development dependency so you can ' \
               'immediately run `rake spec` afterwards.  Use `--no-bundle-install` if you want to add other gems to ' \
               'the gemspec or Gemfile before installing or you\'re just rerunning install to update the templated ' \
               'files and the dependencies are already in your bundle.',
         type: :boolean
  option :github_owner,
         default: 'rapid7',
         desc: 'The owner of the github repo for this gem.  Used to generate links in CONTRIBUTING.md',
         type: :string
  option :ruby_versions,
         default: ['jruby', 'ruby-2.1'],
         desc: 'Ruby versions that the gem should be released for on rubygems.org as part of CONTRIBUTING.md',
         type: :array
  # Adds 'metasploit-version' as a development dependency in this project's gemspec.
  #
  # @return [void]
  def install
    ensure_development_dependency
    template('lib/versioned/version.rb.tt', "lib/#{namespaced_path}/version.rb")
    install_bundle
    template('CHANGELOG.md.tt', 'CHANGELOG.md')
    template('CONTRIBUTING.md.tt', 'CONTRIBUTING.md')
    template('RELEASING.md.tt', 'RELEASING.md')
    template('UPGRADING.md.tt', 'UPGRADING.md')
    setup_rspec
  end

  private

  # Capitalizes words by converting the first character of `word` to upper case.
  #
  # @param word [String] a lower case string
  # @return [String]
  def capitalize(word)
    word[0, 1].upcase + word[1 .. -1]
  end

  # Ensures that the {#gemspec_path} contains a development dependency on {GEM_NAME}.
  #
  # Adds `spec.add_development_dependency 'metasploit_version', '~> <semantic version requirement>'` if {#gemspec_path}
  # does not have such an entry.  Otherwise, updates the `<semantic version requirement>` to match this version of
  # `metasploit-version`.
  #
  # @return [void]
  # @raise (see #gemspec_path)
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

  # The name of the gemspec in the current working directory.
  #
  # @return [String] relative path to the current working directory's gemspec.
  # @raise [SystemExit] if no gemspec is found
  def gemspec_path
    unless instance_variable_defined? :@gemspec
      path = "#{name}.gemspec"

      unless File.exist?(path)
        shell.say 'No gemspec found'
        exit 1
      end

      @gemspec_path = path
    end

    @gemspec_path
  end

  # The URL of the github repository.  Used to calculate the fork and issues URL in `CONTRIBUTING.md`.
  #
  # @return [String] https url to github repository
  def github_url
    @github_url ||= "https://github.com/#{options[:github_owner]}/#{name}"
  end

  # `bundle install` if the :bundle_install options is `true`
  #
  # @return [void]
  def install_bundle
    if options[:bundle_install]
      system('bundle', 'install')
    end
  end

  # The name of the gem.
  #
  # @return [String] name of the gem.  Assumed to be the name of the pwd as it should match the repository name.
  def name
    @name ||= File.basename(Dir.pwd)
  end

  # The fully-qualified namespace for the gem.
  #
  # @param [String]
  def namespace_name
    @namespace_name ||= namespaces.join('::')
  end

  # List of `Module#name`s making up the {#namespace_name the fully-qualifed namespace for the gem}.
  #
  # @return [Array<String>]
  def namespaces
    unless instance_variable_defined? :@namespaces
      underscored_words = name.split('_')
      capitalized_underscored_words = underscored_words.map { |underscored_word|
        capitalize(underscored_word)
      }
      capitalized_hyphenated_name = capitalized_underscored_words.join
      hyphenated_words = capitalized_hyphenated_name.split('-')

      @namespaces = hyphenated_words.map { |hyphenated_word|
        capitalize(hyphenated_word)
      }
    end

    @namespaces
  end

  # The relative path of the gem under `lib`.
  #
  # @return [String] Format of `[<parent>/]*<child>`
  def namespaced_path
    @namespaced_path ||= name.tr('-', '/')
  end

  # The prerelease version.
  #
  # @return [nil] if on master or HEAD
  # @return [String] if on a branch
  def prerelease
    unless instance_variable_defined? :@prerelease
      branch = Metasploit::Version::Branch.current
      parsed = Metasploit::Version::Branch.parse(branch)

      if parsed.is_a? Hash
        prerelease = parsed[:prerelease]

        if prerelease
          @prerelease = prerelease
        end
      end
    end

    @prerelease
  end

  # Generates `.rspec`, `Rakefile`, `version_spec.rb`, `<namespace>_spec.rb` and `spec/spec_helper.rb`
  #
  # @return [void]
  def setup_rspec
    template('.rspec.tt', '.rspec')
    template('Rakefile.tt', 'Rakefile')
    template('spec/lib/versioned/version_spec.rb.tt', "spec/#{version_path.sub(/\.rb$/, '_spec.rb')}")
    template('spec/lib/versioned_spec.rb.tt', "spec/lib/#{namespaced_path}_spec.rb")
    template('spec/spec_helper.rb.tt', 'spec/spec_helper.rb')
  end

  # Path to the `version.rb` for the gem.
  #
  # @return [String]
  def version_path
    @version_path ||= "lib/#{namespaced_path}/version.rb"
  end
end