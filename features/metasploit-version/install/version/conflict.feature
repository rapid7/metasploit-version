Feature: metasploit-version install handles conflicts in 'version.rb'

  `metasploit-version install` will detect if the a version.rb file already exists and prompt the user for conflict
  resolution.  The user can also non-interactive force the file to be overwritten with --force or skip overwriting the
  file with --skip.

  Background:
    Given I build gem from project's "metasploit-version.gemspec"
    And I'm using a clean gemset "metasploit_version_install_conflict"
    And I install latest local "metasploit-version" gem
    And I successfully run `bundle gem metasploit_version_install_conflict`
    And I cd to "metasploit_version_install_conflict"

  Scenario: Prompts for confirmation if --force or --skip is not used
    When I run `metasploit-version install` interactively
    # to overwrite version.rb
    And I type "y"
    # to overwrite Rakefile
    And I type "y"
    Then the output should contain "conflict  lib/metasploit_version_install_conflict/version.rb"
    And the output should contain "force  lib/metasploit_version_install_conflict/version.rb"

  Scenario: --force will force update version.rb
    When I successfully run `metasploit-version install --force`
    Then the output should contain "force  lib/metasploit_version_install_conflict/version.rb"

  Scenario: --skip will not update version.rb
    When I successfully run `metasploit-version install --skip`
    Then the output should contain "skip  lib/metasploit_version_install_conflict/version.rb"
