require 'spec_helper'

describe Metasploit::Version do
  it_should_behave_like 'Metasploit::Version GEM_VERSION constant'
  it_should_behave_like 'Metasploit::Version VERSION constant'
end