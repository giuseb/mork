require 'spec_helper'

module Mork
  describe Coord do
    let(:co) { Coord.new 50 }

    it 'creates a Coord' do
      expect(co).to be_a Coord
    end

    context 'returning coordinates' do
      it 'works with just the width' do
        expect(co.x).to eq  0
        expect(co.y).to eq  0
        expect(co.w).to eq 50
        expect(co.h).to eq 50
      end

      it 'yields modified coords with a coefficient' do
        c = Coord.new 50, cx: 1.07
        expect(c.x).to eq  0
        expect(c.y).to eq  0
        expect(c.w).to eq (50 * 1.07).round
        expect(c.h).to eq (50 * 1.07).round
      end

      it 'works with all arguments' do
        c = Coord.new 50, cy: 1.04, h: 60, y: 25, cx: 0.97, x: 19
        expect(c.y).to eq (25 * 1.04).round
      end
    end

    context 'returning strings for imagemagick use' do
      describe '#rect_points' do
        it 'returns a well-formed string' do
          expect(co.rect_points).to eq "0 0 50 50"
        end
      end

      describe '#cropper' do
        it 'returns a well-formed string' do
          expect(co.cropper).to eq "50x50+0+0"
        end
      end
    end

    it 'returns an X range' do
      expect(co.x_rng).to eq(0...50)
    end

    it 'returns a Y range' do
      expect(co.y_rng).to eq(0...50)
    end
  end
end
