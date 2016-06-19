require 'spec_helper'
include Mork::Extensions

module Mork
  describe Grid do
    let(:base) { symbolize YAML.load_file('spec/samples/base_layout.yml') }

    describe 'hash vs yaml' do
      it 'makes sure that the default grid and the base_layout.yml are equivalent' do
        expect(base).to eq(Grid.new.default_grid)
      end
    end

    context 'init params' do
      it 'does not work with an integer' do
        expect {Grid.new 1}.to raise_error ArgumentError
      end
    end

    context 'default grid' do
      describe '#max_questions' do
        it 'returns the maximum number of questions in a sheet' do
          expect(Grid.new.max_questions).to eq base[:items][:columns]*base[:items][:rows]
        end
      end

      describe '#barcode_bits' do
        it 'returns the number of bits used to define the form barcode' do
          expect(Grid.new.send(:barcode_bits)).to eq base[:barcode][:bits]
        end
      end
    end
  end
end
