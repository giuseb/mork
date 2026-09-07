require 'spec_helper'

module Mork
  describe Magicko do
    let(:sh) { sample_img :jdoe1 }
    let(:ma) { Magicko.new sh.image_path }
    let(:co) { Coord.new 50}
    let(:pp) { { tl: {x: 10, y: 10}, tr: {x: 1000, y: 10}, bl: {x: 10, y: 1700}, br: {x: 1000, y: 1700}} }

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

    describe 'ImageMagick command selection' do
      let(:status) { instance_double(Process::Status, success?: true) }

      it 'uses ImageMagick 6 convert through MiniMagick and preserves raw bytes' do
        magicko = ma
        allow(MiniMagick).to receive(:imagemagick7?).and_return(false)
        expect(Open3).to receive(:capture3).with(
          'convert', '-depth', '8', sh.image_path, '-crop', co.cropper, 'gray:-'
        ).and_return(["\x00\x0a\xff".b, '', status])

        expect(magicko.rm_patch(co)).to eq [0, 10, 255]
      end

      it 'uses ImageMagick 7 magick through MiniMagick' do
        magicko = ma
        allow(MiniMagick).to receive(:imagemagick7?).and_return(true)
        expect(Open3).to receive(:capture3).with(
          'magick', '-depth', '8', sh.image_path, '-crop', co.cropper, 'gray:-'
        ).and_return(["\x00".b, '', status])

        expect(magicko.rm_patch(co)).to eq [0]
      end
    end

    describe 'overlay stroke width' do
      it 'defaults to the legacy 3-pixel width' do
        expect(ma.overlay_stroke_width).to eq 3
      end

      it 'uses the configured width for green outlines' do
        ma.overlay_stroke_width = 6
        ma.outline [co], false
        expect(ma.instance_variable_get(:@cmd)).to include([:strokewidth, 6])
      end

      it 'draws a semitransparent green fill over the cell' do
        ma.highlight_green [co], false
        commands = ma.instance_variable_get(:@cmd)
        expect(commands).to include([:stroke, 'none'])
        expect(commands).to include([:fill, 'rgba(0, 255, 0, 0.3)'])
        expect(commands).to include([:draw, 'rectangle 0 0 50 50'])
      end
    end
  end
end
