require 'spec_helper'

module Mork
  describe NPatch do
    let(:rgm) { sample_img(:reg_mark) }
    let(:mim) { Mimage.new(rgm.filename) }
    
    describe ".new" do
      it "should create an NPatch" do
        NPatch.new(mim).should be_an(NPatch)
      end
    end
    
    describe "#dark_centroid" do
      it "should return the correct X" do
        x, y = NPatch.new(mim).dark_centroid
        x.should == rgm.info["centroid_x"]
      end
      
      it "should return the correct Y" do
        x, y = NPatch.new(mim).dark_centroid
        y.should == rgm.info["centroid_y"]
      end
    end
  end
end

# describe "#dark_centroid_on" do
#   it "returns the actual xy offset of the tl registration mark" do
#     x, y = mim.dark_centroid_on({x: 0, y: 0, w: 180, h: 180})
#     x.should be_within(2).of(smp.reg_marks["tl_x"])
#     y.should be_within(2).of(smp.reg_marks["tl_y"])
#   end
#   
#   it "returns the actual xy offset of the tr registration mark" do
#     x, y = mim.dark_centroid_on({x: smp.width-180, y: 0, w: 180, h: 180})
#     x.should be_within(2).of(smp.reg_marks["tr_x"])
#     y.should be_within(2).of(smp.reg_marks["tr_y"])
#   end
#   
#   it "returns the actual xy offset of the br registration mark" do
#     x, y = mim.dark_centroid_on({x: smp.width-180, y: smp.height-180, w: 180, h: 180})
#     x.should be_within(2).of(smp.reg_marks["br_x"])
#     y.should be_within(2).of(smp.reg_marks["br_y"])
#   end
#   
#   it "returns the actual xy offset of the bl registration mark" do
#     x, y = mim.dark_centroid_on({x: 0, y: smp.height-180, w: 180, h: 180})
#     x.should be_within(2).of(smp.reg_marks["bl_x"])
#     y.should be_within(2).of(smp.reg_marks["bl_y"])
#   end
# end
