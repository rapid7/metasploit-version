shared_examples_for 'Metasploit::Version VERSION constant' do
  context 'CONSTANTS' do
    context 'VERSION' do
      subject(:version) do
        described_class::VERSION
      end

      it 'is Version.full' do
        expect(version).to eq(described_class::Version.full)
      end
    end
  end
end