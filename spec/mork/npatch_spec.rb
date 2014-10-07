require 'spec_helper'

module Mork
  describe NPatch do
    let(:rm) { NPatch.new 'spec/samples/rm01.jpeg', 134, 104 }
    
    describe ".new" do
      it "should create an NPatch" do
        expect(rm).to be_an NPatch
      end
    end
    
    describe '#dark_centroid' do
      it 'computes centers for rm01' do
        np = NPatch.new 'spec/samples/rm01.jpeg', 134, 104
        expect(np.dark_centroid).to eq [50, 60]
        np = NPatch.new 'spec/samples/rm02.jpeg', 114, 117
        expect(np.dark_centroid).to eq [69, 71]
        np = NPatch.new 'spec/samples/rm03.jpeg', 124, 105
        expect(np.dark_centroid).to eq [71, 61]
        np = NPatch.new 'spec/samples/rm04.jpeg', 144, 117
        expect(np.dark_centroid).to eq [84, 52]
        np = NPatch.new 'spec/samples/rm05.jpeg', 144, 117
        expect(np.dark_centroid).to eq [84, 52]
      end
    end
    
    describe '#average' do
      it 'works' do
        c = {x: 30, y: 35, w: 46, h: 46}
        puts rm.average c
        c = {x: 85, y: 10, w: 46, h: 46}
        puts rm.average c
      end
    end
    
    # describe "#dark_centroid" do
    #   it "should return the correct X" do
    #     x, y = NPatch.new(mim).dark_centroid
    #     x.should == rgm.info["centroid_x"]
    #   end
    #
    #   it "should return the correct Y" do
    #     x, y = NPatch.new(mim).dark_centroid
    #     y.should == rgm.info["centroid_y"]
    #   end
    # end
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
