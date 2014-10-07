require 'spec_helper'

module Mork
  describe GridOMR do
    before(:each) do
      @grom = GridOMR.new 'spec/samples/layout.yml'
      @grom.set_page_size 1601, 2281
    end
      
    describe '#choice_cell_area' do
      it 'returns the coordinates of the first choice cell' do
        @grom.choice_cell_area(0,0).should == {x: 63, y: 436, w: 51, h: 41}
      end
      
      it 'returns the coordinates of the last choice cell' do
        @grom.choice_cell_area(119,4).should == {x: 1411, y: 2108, w: 51, h: 41}
      end
    end
    
    describe '#barcode_bit_area' do
      # it 'returns the coordinates of the first barcode bit area' do
      #   @grom.barcode_bit_area(0).should == {x: 160, y: 2260, w: 25, h: 21}
      # end
      #
      # it 'returns the coordinates of the last barcode bit area' do
      #   @grom.barcode_bit_area(39).should == {x: 1475, y: 2260, w: 25, h: 21}
      # end
      #
      # it 'fails if an invalid barcode bit is requested' do
      #   lambda { @grom.barcode_bit_area(40) }.should raise_error
      # end
    end

    describe '#rm_search_area' do
      context 'on the first iteration' do
        it 'returns an {:x, :y, :w, :h} hash of coordinates in pixels for the :tl reg_mark corner' do
          c = @grom.rm_search_area :tl, 0
          c.should == {x: 15, y: 15, w: 91, h: 92}
        end

        it 'returns an {:x, :y, :w, :h} hash of coordinates in pixels for the :tr reg_mark corner' do
          c = @grom.rm_search_area :tr, 0
          c.should == { x: 1494, y: 15, w: 91, h: 92 }
        end

        it 'returns an {:x, :y, :w, :h} hash of coordinates in pixels for the :br reg_mark corner' do
          c = @grom.rm_search_area :br, 0
          c.should == { x: 1494, y: 2173, w: 91, h: 92 }
        end

        it 'returns an {:x, :y, :w, :h} hash of coordinates in pixels for the :bl reg_mark corner' do
          c = @grom.rm_search_area :bl, 0
          c.should == { x: 15, y: 2173, w: 91, h: 92 }
        end
      end

      context 'on the third iteration' do
        it 'returns an {:x, :y, :w, :h} hash of coordinates in pixels for the :tl reg_mark corner' do
          c = @grom.rm_search_area :tl, 2
          c.should == { x: 15, y: 15, w: 130, h: 131 }
        end

        it 'returns an {:x, :y, :w, :h} hash of coordinates in pixels for the :tr reg_mark corner' do
          c = @grom.rm_search_area :tr, 2
          c.should == { x: 1456, y: 15, w: 130, h: 131 }
        end

        it 'returns an {:x, :y, :w, :h} hash of coordinates in pixels for the :br reg_mark corner' do
          c = @grom.rm_search_area :br, 2
          c.should == { x: 1456, y: 2135, w: 130, h: 131 }
        end

        it 'returns an {:x, :y, :w, :h} hash of coordinates in pixels for the :bl reg_mark corner' do
          c = @grom.rm_search_area :bl, 2
          c.should == { x: 15, y: 2135, w: 130, h: 131 }
        end
      end
    end
    
    describe '#rm_edgy_x' do
      it 'returns the minimum acceptable number of pixels from the regmark center to the edge of the rm_search_area' do
        @grom.rm_edgy_x.should == 24
      end
      it 'returns an integer' do
        @grom.rm_edgy_x.should be_a Fixnum
      end
    end

    describe '#rm_edgy_y' do
      it 'returns the minimum acceptable number of pixels from the regmark center to the edge of the rm_search_area' do
        @grom.rm_edgy_y.should == 24
      end
      it 'returns an integer' do
        @grom.rm_edgy_y.should be_a Fixnum
      end
    end
    
    describe '#rm_max_search_area_side' do
      it 'returns the maximum extent of the regmark search area, 1/4 of the raw image horizontal pixels' do
        @grom.rm_max_search_area_side.should == 400
      end
      it 'returns an integer' do
        @grom.rm_max_search_area_side.should be_a Fixnum
      end
    end

    describe '#max_choices_per_question' do
      it 'returns the maximum number of choice cells per question' do
        @grom.max_choices_per_question.should == 5
      end
    end
    
    describe '#paper_white_area' do
      it 'returns the coordinates of the white area used for barcode calibration' do
        @grom.paper_white_area.should == {x: 93, y: 2260, w: 25, h: 21}
      end
    end
    
    describe '#ink_black_area' do
      it 'returns the coordinates of the barcode calibration bar' do
        @grom.ink_black_area.should == {x: 126, y: 2260, w: 25, h: 21}
      end
    end
  end
end