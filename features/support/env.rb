require 'aruba/cucumber'
# only does jruby customization if actually in JRuby
require 'aruba/jruby'

Before do
  @aruba_timeout_seconds = 10 * 60
end
