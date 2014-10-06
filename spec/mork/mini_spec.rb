require 'spec_helper'

module Mork
  describe Mini do
    describe '.new' do
      let(:mini) { Mini.new 'spec/samples/sample_gray.jpg' }
      it 'inspects the source file' do
        expect(mini.height).to eq 2339
        expect(mini.width).to  eq 1654
      end
      
      it 'creates a binary file with the pixels' do
        expect(mini.length).to eq 2339 * 1654
      end
      
      it 'instantiates a NArray' do
        expect(mini.pix).to be_a NArray
      end
    end
    
    describe '#dark_centroid' do
      let(:mini) { Mini.new 'spec/samples/reg_mark.jpg' }
      it 'returns the coordinates' do
        x, y = mini.dark_centroid
        expect(x).to eq 90
        expect(y).to eq 93
        
      end
    end
  end
end