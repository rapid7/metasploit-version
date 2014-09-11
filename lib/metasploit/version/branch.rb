require 'metasploit/version'

# Regular expressions for parsing the branch name into its component parts
module Metasploit::Version::Branch
  #
  # CONSTANTS
  #

  # Regular expression that matches, but does not capture an optional prefix of 'ref/remotes' for when a branch name is
  # fully qualified on Jenkins.
  JENKINS_PREFIX_REGEXP = %r{(?:ref/remotes/)?}

  # Matches runs of alphanumeric characters that are valid in prerelease segments.  Prerelease segments must be
  # separated by `.` or `-`.
  PRERELEASE_SEGMENT_REGEXP = /[0-9a-zA-Z]+/

  # Version pattern allowed by Rubygems for pre-release: runs of alphanumeric characters separated by `.` or `-`.
  # Group is captured to `:prerelease` name.
  PRERELEASE_REGEXP = /(?<prerelease>#{PRERELEASE_SEGMENT_REGEXP}([-.]#{PRERELEASE_SEGMENT_REGEXP})*)/

  # Regular expression that matches exactly a staging branch.  It may
  # {JENKINS_PREFIX_REGEXP optionally start with `ref/remotes`}, followed by a type of `staging`, no story ID, and a
  # {PRERELEASE_REGEXP pre-release name}.
  #
  # @example Staging Branch
  #   'staging/long-running'
  #
  # @example Staging Branch on Jenkins
  #   'ref/remotes/origin/staging/long-running'
  STAGING_REGEXP = %r{
    \A
    #{JENKINS_PREFIX_REGEXP}
    (?<type>staging)
    /
    #{PRERELEASE_REGEXP}
    \z
  }x

  # Regular expression that matches exactly a chore, feature or bug branch.  It may
  # {JENKINS_PREFIX_REGEXP optionally start with `ref/remotes`}, followed by a type of `staging`, story ID, and a
  # {PRERELEASE_REGEXP pre-release name}.
  #
  # @example Bug Branch
  #   'bug/MSP-666/nasty'
  #
  # @example Bug Branch on Jenkins
  #   'ref/remotes/origin/bug/MSP-666/nasty'
  #
  # @example Chore Branch
  #   'chore/MSP-1234/recurring'
  #
  # @example Chore Branch on Jenkins
  #   'ref/remotes/origin/chore/MSP-1234/recurring'
  #
  # @example Feature Branch
  #   'feature/MSP-31337/cool'
  #
  # @example Feature Branch on Jenkins
  #   'ref/remotes/origin/feature/MSP-31337/cool'
  #
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

  # Regular expression that matches separator used between {PRERELEASE_SEGMENT_REGEXP prerelease segments} for gem
  # versions and tag versions.
  VERSION_PRERELEASE_SEGMENT_SEPARATOR_REGEXP = /\.pre\./

  # Regular expression that exactly matches a release or pre-release version tag prefixed with `v` and followed by
  # the major, minor, and patch numbers separated by '.' with an optional prerelease version suffix.
  #
  # @example Releease Tag
  #   'v1.2.3'
  #
  # @example Prerelease Tag
  #   'v1.2.3.pre.cool'
  #
  VERSION_REGEXP = %r{
    \A
    v(?<major>\d+)
    \.
    (?<minor>\d+)
    \.
    (?<patch>\d+)
    (?:
      #{VERSION_PRERELEASE_SEGMENT_SEPARATOR_REGEXP}
      (?<gem_version_prerelease>
        #{PRERELEASE_SEGMENT_REGEXP}
        (#{VERSION_PRERELEASE_SEGMENT_SEPARATOR_REGEXP}#{PRERELEASE_SEGMENT_REGEXP})*
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