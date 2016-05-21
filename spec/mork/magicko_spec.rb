require 'spec_helper'

module Mork
  describe Magicko do
    let(:sh) { sample_img :slanted }
    let(:ma) { Magicko.new sh.filename }
    let(:pp) { { tl: {x: 10, y: 10}, tr: {x: 1000, y: 10}, bl: {x: 10, y: 1700}, br: {x: 1000, y: 1700}} }

    it 'exists' do
      expect(Magicko.new 1).to be_a Magicko
    end

    describe '#width' do
      it 'returns the image width' do
        expect(ma.width).to eq sh.width
      end
    end

    describe '#height' do
      it 'returns the image height' do
        expect(ma.height).to eq sh.height
      end
    end

    describe '#raw_patch' do
      it 'returns an NPatch for the entire raw image' do
        expect(ma.raw_patch).to be_an NPatch
      end

      it 'returns an NPatch of appropriate size' do
        expect(ma.raw_patch.length).to eq sh.height*sh.width
      end
    end

    describe '#reg_patch' do
      it 'returns an NPatch for the registered image' do
        expect(ma.reg_patch pp).to be_an NPatch
      end

      it 'returns an NPatch of the same size as the origina image' do
        expect(ma.reg_patch(pp).length).to eq sh.height*sh.width
      end
    end

    describe '#rm_patch' do
      it 'exists' do
        expect(ma.rm_patch :tl, 100).to be_an NPatch
      end
    end
  end
end
