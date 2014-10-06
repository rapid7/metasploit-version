source 'https://rubygems.org'

# Specify your gem's dependencies in metasploit-version.gemspec
gemspec

group :test do
  # Test the shared example
  gem 'aruba', github: 'rapid7/aruba', tag: 'v0.6.3.pre.metasploit.pre.yard.pre.port'

  platforms :mri, :jruby do
    # Upload spec coverage to codeclimate.com
    gem 'codeclimate-test-reporter', require: false
    # Upload spec coverage to coveralls.io
    gem 'coveralls', require: false
    # code coverage for specs
    gem 'simplecov', require: false
  end

  # Test the shared example
  gem 'cucumber'
end
