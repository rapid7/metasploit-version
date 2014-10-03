Feature: metasploit-version install's <namespace>_spec.rb generates proper namespace for gem name

  The <namespace>_spec.rb that checks that GEM_VERSION and VERSION are defined correctly will use the fully-qualified
  name for the gem namespace with proper conversion of underscored and dashes in the gem name to camel case and separate
  modules, respectively.

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
    Then the file "<namespace_spec_rb_path>" should contain exactly:
      """
      RSpec.describe <gem_namespace_module> do
        it_should_behave_like 'Metasploit::Version GEM_VERSION constant'
        it_should_behave_like 'Metasploit::Version VERSION constant'
      end

      """

    Examples:
      | gem_name             | namespace_spec_rb_path                | gem_namespace_module |
      | single               | spec/lib/single_spec.rb               | Single               |
      | two_words            | spec/lib/two_words_spec.rb            | TwoWords             |
      | parent-child         | spec/lib/parent/child_spec.rb         | Parent::Child        |
      | two_words-child      | spec/lib/two_words/child_spec.rb      | TwoWords::Child      |
      | parent-two_words     | spec/lib/parent/two_words_spec.rb     | Parent::TwoWords     |
      | two_words-more_words | spec/lib/two_words/more_words_spec.rb | TwoWords::MoreWords  |