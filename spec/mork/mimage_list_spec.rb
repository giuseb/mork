require 'spec_helper'

module Mork
  # describe MimageList do
  #   before(:all) do
  #     tpg = sample_img(:two_pages)
  #     @mlist = MimageList.new(tpg.filename)
  #   end
  #
  #   describe ".new" do
  #     it "should raise an error unless called with a string" do
  #       lambda {
  #         MimageList.new(666)
  #       }.should raise_error
  #     end
  #   end
  #
  #   describe "[]" do
  #     it "should return the 1st mimage in the stack" do
  #       @mlist[0].should be_a(Mimage)
  #     end
  #
  #     it "should return the last mimage in the stack" do
  #       @mlist[1].should be_a(Mimage)
  #     end
  #   end
  #
  #   describe "each" do
  #     it "should loop over all images" do
  #       @mlist.each do |m|
  #         puts m.inspect
  #         m.should be_a(Mimage)
  #       end
  #     end
  #   end
  # end
end