require 'spec_helper'

module Mork
  describe NPatch do
    describe '#centroid' do
      it 'computes centers for rm0X' do
        np = make 'spec/samples/rm01.jpeg', 134, 104
        expect(np.centroid[0]).to eq 50
        expect(np.centroid[1]).to eq 60
        np = make 'spec/samples/rm02.jpeg', 114, 117
        expect(np.centroid[0]).to eq 69
        expect(np.centroid[1]).to eq 71
        np = make 'spec/samples/rm03.jpeg', 124, 105
        expect(np.centroid[0]).to eq 71
        expect(np.centroid[1]).to eq 61
        np = make 'spec/samples/rm04.jpeg', 144, 117
        expect(np.centroid[0]).to eq 84
        expect(np.centroid[1]).to eq 52
        np = make 'spec/samples/rm05.jpeg', 144, 117
        expect(np.centroid[0]).to eq 84
        expect(np.centroid[1]).to eq 52
      end
    end

    describe '#average' do
      it 'works' do
        np = make 'spec/samples/rm00.jpeg', 100, 100
        expect(np.average Coord.new(100)).to be_within(1).of(234)
      end
    end

    describe '#stddev' do
      it 'works' do
        np = make 'spec/samples/rm00.jpeg', 100, 100
        expect(np.stddev Coord.new(100)).to be_within(1).of(53)
      end
    end

    def make(fname, w, h)
      b = IO.read("|convert #{fname} gray:-").unpack 'C*'
      NPatch.new b, w, h
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

# let(:impath)  { 'spec/samples/rm01.jpeg' }
# let(:imbytes) { IO.read("|convert #{impath} gray:-").unpack 'C*' }
# let(:rm)      { NPatch.new imbytes, 134, 104 }

# describe ".new" do
#   it "should create an NPatch" do
#     expect(rm).to be_an NPatch
#   end
# end

