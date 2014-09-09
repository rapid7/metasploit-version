require 'metasploit/version'

# Regular expressions for parsing the branch name into its component parts
module Metasploit::Version::Branch
  JENKINS_PREFIX_REGEXP = %r{(?:ref/remotes/)?}
  PRERELEASE_SEGMENT_REGEXP = /[0-9a-zA-Z]+/
  # Version pattern allowed by Rubygems for pre-release (i.e. summary in BRANCH_REGEXP)
  PRERELEASE_REGEXP = /(?<prerelease>#{PRERELEASE_SEGMENT_REGEXP}([-.]#{PRERELEASE_SEGMENT_REGEXP})?)/

  STAGING_REGEXP = %r{
    \A
    #{JENKINS_PREFIX_REGEXP}
    (?<type>staging)
    /
    #{PRERELEASE_REGEXP}
    \z
  }x
  STORY_REGEXP = %r{
    \A
    #{JENKINS_PREFIX_REGEXP}
    (?<type>bug|chore|feature)
    /
    (?<story>[^/]+)
    /
    #{PRERELEASE_REGEXP}
    \z
  }x
  VERSION_PRERELEASE_SEGMENT_SEPARATOR = /\.pre\./
  VERSION_REGEXP = %r{
    \A
    v(?<major>\d+)
    \.
    (?<minor>\d+)
    \.
    (?<patch>\d+)
    (?:
      #{VERSION_PRERELEASE_SEGMENT_SEPARATOR}
      (?<gem_version_prerelease>
        #{PRERELEASE_SEGMENT_REGEXP}
        (#{VERSION_PRERELEASE_SEGMENT_SEPARATOR}#{PRERELEASE_SEGMENT_REGEXP})*
      )
    )?
    \z
  }x

  # The current branch name from travis-ci or git.
  #
  # @return [String]
  def self.current
    branch = ENV['TRAVIS_BRANCH']

    if branch.nil? || branch.empty?
      branch = `git rev-parse --abbrev-ref HEAD`.strip
    end

    branch
  end

  # Parses the branch
  #
  # @param branch [String] the branch name
  # @return ['HEAD'] if `branch` is 'HEAD' (such as in a detached head state for git)
  # @return ['master'] if `branch` is `master`
  # @return [Hash{type: 'staging', prerelease: String}] if a staging branch
  # @return [Hash{type: String, story: String, prerelease: String}] if not a staging branch
  # @return [Hash{major: Integer, minor: Integer, patch: Integer, prerelease: String}]
  # @return [nil] if `branch` does not match any of the formats
  def self.parse(branch)
    if ['HEAD', 'master'].include? branch
      branch
    else
      match = branch.match(STAGING_REGEXP)

      if match
        {
            prerelease: match[:prerelease],
            type: match[:type]
        }
      else
        match = branch.match(STORY_REGEXP)

        if match
          {
              prerelease: match[:prerelease],
              story: match[:story],
              type: match[:type]
          }
        else
          match = branch.match(VERSION_REGEXP)

          if match
            prerelease = prerelease(match[:gem_version_prerelease])

            {
                major: match[:major].to_i,
                minor: match[:minor].to_i,
                patch: match[:patch].to_i,
                prerelease: prerelease
            }
          end
        end
      end
    end
  end

  # Replaces `.pre.` in `gem_version_prerelease` with `-` to undo conversion to rubygems 1.8.6 compatible pre-release
  # version.
  #
  # @return [String] unless `gem_version_prerelease` is `nil`.
  # @return [nil] if `gem_version_prerelease` is `nil`.
  def self.prerelease(gem_version_prerelease)
    unless gem_version_prerelease.nil?
      gem_version_prerelease.gsub('.pre.', '-')
    end
  end
end