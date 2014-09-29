require 'spec_helper'

module Mork
  describe Mimage do
    let(:smp) { sample_img(:sample01) }
    let(:mim) { Mimage.new(smp.filename) }
    
    describe ".new" do
      it "should create a Mimage from a string pointing to an existing bitmap file" do
        mim.should be_a(Mimage)
      end
      it "should create a Mimage from an existing Magick::ImageList object" do
        i = Magick::ImageList.new smp.filename
        Mimage.new(i).should be_a(Mimage)
      end
      it "should create a Mimage from an existing Magick::Image object" do
        i = Magick::ImageList.new smp.filename
        Mimage.new(i.first).should be_a(Mimage)
      end
      it "should raise an error if called with a fixnum" do
        lambda { Mimage.new 1 }.should raise_error
      end
    end
    
    describe "#crop" do
      it "should return a Mimage" do
        mim.crop({x: 0, y: 0, w: 10, h: 10}).should be_a(Mimage)
      end
      it "should return a Mimage of the correct width" do
        i = mim.crop({x: 0, y: 0, w: 20, h: 10})
        i.width.should == 20
      end
      it "should return a Mimage of the correct height" do
        i = mim.crop({x: 0, y: 0, w: 10, h: 10})
        i.height.should == 10
      end
    end
    
    describe "#crop!" do
      it "should reduce the Mimage to the correct width" do
        mim.crop!({x: 0, y: 0, w: 20, h: 10}).width.should == 20
      end
      it "should reduce the Mimage to the correct height" do
        mim.crop!({x: 0, y: 0, w: 20, h: 10}).height.should == 10
      end
    end
  end
end