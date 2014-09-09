shared_examples_for 'Metasploit::Version GEM_VERSION constant' do
  context 'CONSTANTS' do
    context 'GEM_VERSION' do
      subject(:version) do
        described_class::GEM_VERSION
      end

      it 'is defined' do
        expect(defined? described_class::GEM_VERSION).not_to be_nil, "expected #{described_class}::GEM_VERSION to be defined"
      end

      it 'is Version.gem' do
        expect(version).to eq(described_class::Version.gem), "expected #{described_class}::GEM_VERSION to equal #{described_class}::Version.gem"
      end
    end
  end
end