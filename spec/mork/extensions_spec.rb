require 'spec_helper'

module Mork
  describe Array do
    it 'computes the average' do
      a = [ 20, 23, 23, 24, 25, 22, 12, 21, 28 ]
      expect(a.mean).to eq 22
    end
  end
end
