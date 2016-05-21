require 'spec_helper'

module Mork
  describe Coord do
    let(:co) { Coord.new 50, 60, 10, 20  }
    it 'creates a Coord' do
      expect(co).to be_a Coord
    end

    it 'returns the coords' do
      expect(co.x).to eq 10
      expect(co.y).to eq 20
      expect(co.w).to eq 50
      expect(co.h).to eq 60
    end

    it 'returns coordinates with simplified call' do
      c = Coord.new 50
      expect(c.x).to eq  0
      expect(c.y).to eq  0
      expect(c.w).to eq 50
      expect(c.h).to eq 50
    end

    it 'returns an X range' do
      expect(co.x_rng).to eq(10...60)
    end

    it 'returns a Y range' do
      expect(co.y_rng).to eq(20...80)
    end
  end
end
