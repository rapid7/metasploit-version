require 'spec_helper'

describe Metasploit::Version do
  it_should_behave_like 'Metasploit::Version VERSION constant'

  context 'root' do
    subject(:root) do
      described_class.root
    end

    it { should be_a Pathname }

    it 'is root of this project' do
      expect(root).to eq(Pathname.new(__FILE__).parent.parent.parent.parent)
    end
  end
end