require 'spec_helper'

module Mork
  describe Array do
    it 'should give the standard deviation' do
      a = [ 20, 23, 23, 24, 25, 22, 12, 21, 29 ]
      a.stdev.should == 4.594682917363407
    end
  end
end
