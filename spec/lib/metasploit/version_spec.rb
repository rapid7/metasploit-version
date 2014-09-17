require 'spec_helper'

describe Metasploit::Version do
  it_should_behave_like 'Metasploit::Version GEM_VERSION constant'
  it_should_behave_like 'Metasploit::Version VERSION constant'

  context 'root' do
    subject(:root) {
      described_class.root
    }

    it { should be_a Pathname }

    it 'is root of this project' do
      expect(root).to eq(Pathname.new(__FILE__).parent.parent.parent.parent)
    end
  end
end