require 'spec_helper'

module Mork
  describe Magicko do
    let(:sh) { sample_img :jdoe1 }
    let(:ma) { Magicko.new sh.image_path }
    let(:co) { Coord.new 50}
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

    describe '#rm_patch' do
      it 'returns an array of bytes for the registration mark area' do
        expect(ma.rm_patch co).to be_an Array
      end

      it 'returns an Array of appropriate size' do
        expect(ma.rm_patch(co).length).to eq 2500
      end
    end

    describe '#registered_bytes' do
      it 'returns an array of bytes for the registered image' do
        expect(ma.registered_bytes pp).to be_an Array
      end

      it 'returns an array of bytes of the same size as the original image' do
        expect(ma.registered_bytes(pp).length).to eq sh.height*sh.width
      end
    end
  end
end
