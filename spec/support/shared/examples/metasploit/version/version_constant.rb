shared_examples_for 'Metasploit::Version VERSION constant' do
  context 'CONSTANTS' do
    context 'VERSION' do
      subject(:version) {
        described_class::VERSION
      }

      it 'is defined' do
        expect(defined? described_class::VERSION).not_to be_nil, "expected #{described_class}::VERSION to be defined"
      end

      it 'is Version.full' do
        expect(version).to eq(described_class::Version.full), "expected #{described_class}::VERSION to equal #{described_class}::Version.full"
      end
    end
  end
end