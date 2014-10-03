Feature: metasploit-version install's 'version_spec.rb' generates proper namespace from gem name

  The version_spec.rb file from metasploit-version will use the fully-qualified name for the Version module under
  the gem's namespace with proper conversion of underscored and dashes in the gem name to camel case and separate
  modules, respectively

  Scenario Outline:
    Given I successfully run `bundle gem <gem_name>`
    And I cd to "<gem_name>"
    And my git identity is configured
    And I successfully run `git commit --message "bundle gem <gem_name>"`
    And I unset the environment variable "TRAVIS_BRANCH"
    And I set the environment variables to:
      | variable            | value |
      | TRAVIS_PULL_REQUEST | false |
    When I successfully run `metasploit-version install --force --no-bundle-install`
    Then the file "<version_spec_rb_path>" should contain exactly:
      """
      RSpec.describe <fully_qualified_version_module> do
        it_should_behave_like 'Metasploit::Version Version Module'
      end

      """

    Examples:
      | gem_name             | version_spec_rb_path                          | fully_qualified_version_module |
      | single               | spec/lib/single/version_spec.rb               | Single::Version                |
      | two_words            | spec/lib/two_words/version_spec.rb            | TwoWords::Version              |
      | parent-child         | spec/lib/parent/child/version_spec.rb         | Parent::Child::Version         |
      | two_words-child      | spec/lib/two_words/child/version_spec.rb      | TwoWords::Child::Version       |
      | parent-two_words     | spec/lib/parent/two_words/version_spec.rb     | Parent::TwoWords::Version      |
      | two_words-more_words | spec/lib/two_words/more_words/version_spec.rb | TwoWords::MoreWords::Version   |
