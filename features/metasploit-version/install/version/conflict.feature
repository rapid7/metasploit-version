Feature: metasploit-version install handles conflicts in 'version.rb'

  `metasploit-version install` will detect if the a version.rb file already exists and prompt the user for conflict
  resolution.  The user can also non-interactive force the file to be overwritten with --force or skip overwriting the
  file with --skip.

  Scenario: Prompts for confirmation if --force or --skip is not used
    Given I successfully run `bundle gem prompt`
    And I cd to "prompt"
    When I run `metasploit-version install` interactively
    And I type "y"
    Then the output should contain "conflict  lib/prompt/version.rb"
    And the output should contain "force  lib/prompt/version.rb"

  Scenario: --force will force update version.rb
    Given I successfully run `bundle gem force`
    And I cd to "force"
    When I successfully run `metasploit-version install --force`
    Then the output should contain "force  lib/force/version.rb"

  Scenario: --skip will not update version.rb
    Given I successfully run `bundle gem skip`
    And I cd to "skip"
    When I successfully run `metasploit-version install --skip`
    Then the output should contain "skip  lib/skip/version.rb"
