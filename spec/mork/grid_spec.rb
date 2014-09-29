require 'spec_helper'

module Mork
  describe Grid do
    context 'init params' do
      it 'does not work with an integer' do
        expect {Grid.new 1}.to raise_error
      end
    end

    context 'default grid' do
      before(:all) do
        @grid = Grid.new 'spec/samples/layout.yml'
      end
      
      describe '#max_questions' do
        it 'returns the maximum number of questions in a sheet' do
          @grid.max_questions.should == 120
        end
      end
      
      describe '#barcode_bits' do
        it 'returns the number of bits used to define the form barcode' do
          @grid.send(:barcode_bits).should == 40
        end
      end
    end

    
    # describe "#cell_x" do
    #   context "for 1st-column questions" do
    #     it "returns the distance from the registration frame of the left edge of the 1st choice" do
    #       grid.send(:cell_x,0,0).should == 7.5
    #     end
    #
    #     it "returns the distance from the registration frame of the left edge of the 2nd choice" do
    #       grid.send(:cell_x,0,1).should == 14.5
    #     end
    #   end
    #
    #   context "for 4th-column questions" do
    #     it "returns the distance from the registration frame of the left edge of the 1st choice" do
    #       grid.send(:cell_x,120,0).should == 157.5
    #     end
    #
    #     it "returns the distance from the registration frame of the left edge of the 2nd choice" do
    #       grid.send(:cell_x,120,1).should == 164.5
    #     end
    #   end
    # end
    #
    # describe "#cell_y" do
    #   it "returns the distance from the registration frame of the top edge of the 1st row of cells" do
    #     grid.send(:cell_y,0).should == 33.5
    #   end
    #
    #   it "returns the distance from the registration frame of the 40th row of cells" do
    #     grid.send(:cell_y,39).should == 267.5
    #   end
    # end
  end
end

# describe "#question_area" do
#   before(:each) do
#     grid.reg_marks(@image)
#   end
#   it "returns a hash" do
#     grid.question_area(1).should be_an_instance_of(Hash)
#   end
#   
#   it "returns the location in pixels of the first question patch" do
#     c = grid.question_area(1)
#     c[:x].should be_within(4).of(90)
#     c[:y].should be_within(4).of(388)
#   end
#   it "returns the location in pixels of the 40th question patch" do
#     c = grid.question_area(40)
#     c[:x].should be_within(4).of(90)
#     c[:y].should be_within(4).of(3120)
#   end
# 
#   it "returns the location in pixels of the 121th question patch" do
#     c = grid.question_area(121)
#     c[:x].should be_within(4).of(1887)
#     c[:y].should be_within(4).of(388)
#   end
# 
#   it "returns the location in pixels of the last question patch" do
#     c = grid.question_area(160)
#     c[:x].should be_within(4).of(1887)
#     c[:y].should be_within(4).of(3120)
#   end
# end

# describe '#ctrl_area_dark' do
#   it 'returns the coordinates of the control cell used to set the darkened threshold' do
#     @grid.ctrl_area_dark.should == {:x=>1479, :y=>329, :w=>51, :h=>41}
#   end
# end
#
# describe '#ctrl_area_light' do
#   it 'returns the coordinates of the control cell used to set the darkened threshold' do
#     @grid.ctrl_area_light.should == {:x=>1538, :y=>329, :w=>51, :h=>41}
#   end
# end
