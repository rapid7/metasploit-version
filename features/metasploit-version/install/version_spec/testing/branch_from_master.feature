Feature: metasploit-version install's 'version_spec.rb' catches when PRERELEASE is missing when branching from master

  The version_spec.rb fiel from metasploit-version will catch errors if the user fails to add the PRERELEASE constant in
  version.rb when branching from master.

  Background:
    Given I successfully run `bundle gem versioned`
    And I cd to "versioned"
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem versioned"`
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |

  Scenario: Installing metasploit-version on feature branch
    Given I successfully run `git checkout -b feature/MSP-1234/metasploit-version`
    And I successfully run `metasploit-version install --force --no-bundle-install`
    Then I successfully run `rake spec`

  Scenario: Branching from master without adding PRERELEASE
    And I successfully run `metasploit-version install --force --no-bundle-install`
    And I successfully run `rake spec`
    And I successfully run `git add *`
    And I successfully run `git commit --all --message "metasploit-version install"`
    And I successfully run `git checkout -b feature/MSP-1337/super-cool`
    Then the file "lib/versioned/version.rb" should not contain "    PRERELEASE ="
    When I run `rake spec`
    Then the exit status should not be 0
    And the output should contain:
      """
             expected Versioned::Version::PRERELEASE to be defined.
             Add the following to Versioned::Version:
      """
    And the output should contain:
      """
                 # The prerelease version, scoped to the {PATCH} version number.
                 PRERELEASE = super-cool
      """
    And the output should contain " 1 failure"
