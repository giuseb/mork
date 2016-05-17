require 'spec_helper'
require 'fileutils'

module Mork
  describe SheetOMR, focus: true do
    # context 'problematic' do
    #   let(:shinfo) { sample_img 'bianchi' }
    #   let(:sheet)  { SheetOMR.new shinfo.filename, shinfo.grid_file }
    #
    #   it 'has a status' do
    #     sheet.status.should == {:tl=>:ok, :tr=>:ok, :br=>:ok, :bl=>:ok, :write=>nil}
    #   end
    #
    #   it 'has a barcode' do
    #     sheet.barcode.should == shinfo.barcode_int
    #   end
    #
    #   it 'writes the registered and marked image' do
    #     sheet.cross_marked
    #     sheet.write 'spec/out/bianchi.jpg'
    #     sheet.status[:write].should == :fail
    #   end
    #
    #   it 'writes the registration areas' do
    #     sheet.highlight_registration
    #     sheet.write_raw 'spec/out/reg_bianchi.jpg'
    #   end
    #
    # end
    #
    context 'slanted' do
      let(:sh) { sample_img 'slanted' }
      let(:sheet) { SheetOMR.new sh.filename }

      it 'gets in trouble' do
        sheet.highlight_registration
        sheet.write_raw 'spec/out/laurout.jpg'
      end

      it 'gets more in trouble' do
        sheet.highlight_marked
        sheet.write 'spec/out/lauraout2.jpg'
      end

      it 'should be valid' do
        expect(sheet.valid?).to be_truthy
      end
    end

    context 'highlighting' do
      # since these specs change the @crop, they must be run in isolation
      # with the SheetOMR rebuilt each time, even though it is time consuming!
      let(:shinfo) { sample_img 'sample-gray' }
      let(:sheet)  { SheetOMR.new shinfo.filename, [5]*100, shinfo.grid_file }

      it 'highlights the registration areas and frame' do
        sheet.highlight_registration
        sheet.write_raw 'spec/out/reg_areas.jpg'
      end

      it 'highlights all choice cells' do
        sheet.highlight_all_choices
        sheet.write 'spec/out/all_highlights.jpg'
      end

      it 'highlights marked cells' do
        sheet.highlight_marked
        sheet.write 'spec/out/marked_highlights.jpg'
      end

      it 'crossed marked cells' do
        sheet.cross_marked
        sheet.write 'spec/out/marked_crosses.jpg'
      end

      it 'outlines some responses' do
        sheet.outline [[1],[1],[2],[2],[3,4],[],[0,1,2,3,4], [],[1],[2],[2],[3,4],[],[0,1,2,3,4]]
        sheet.write 'spec/out/outlines.jpg'
      end

      it 'cross some responses' do
        sheet.cross [[1],[1],[2],[2],[3,4],[],[0,1,2,3,4], [],[1],[2],[2],[3,4],[],[0,1,2,3,4]]
        sheet.write 'spec/out/crosses.jpg'
      end

      it 'outlines some responses in-place (rewriting the source image)' do
        FileUtils.cp shinfo.filename, 'spec/out/inplace.jpg'
        tsheet = SheetOMR.new 'spec/out/inplace.jpg', [5]*100, shinfo.grid_file
        tsheet.outline [[1],[1],[2],[2],[3,4],[],[0,1,2,3,4], [],[1],[2],[2],[3,4],[],[0,1,2,3,4]]
        tsheet.write
      end

      it 'highlights marked cells and outline correct responses' do
        sheet.highlight_marked
        sheet.outline [[1],[1],[2],[2],[3,4],[],[0,1,2,3,4], [],[1],[2],[2],[3,4],[],[0,1,2,3,4]]
        sheet.write 'spec/out/marks_and_outs.jpg'
      end

      it 'highlights marked cells of a problematic one' do
        si = sample_img 'silvia'
        s = SheetOMR.new si.filename, [5]*100, si.grid_file
        s.highlight_marked
        s.write 'spec/out/problem.jpg'
      end

      it 'highlights the barcode' do
        si = sample_img 'sample-gray'
        s = SheetOMR.new si.filename, [5]*100, si.grid_file
        s.highlight_barcode
        s.write 'spec/out/code_bits.jpg'
      end
    end

    context 'marking a nicely printed and scanned sheet' do
      before(:all) do
        @shinfo = sample_img 'sample-gray'
        @sheet = SheetOMR.new @shinfo.filename, [5]*120, @shinfo.grid_file
      end

      describe '#valid?' do
        it 'returns true' do
          @sheet.valid?.should be_truthy
        end
      end

      describe '#marked?' do
        it 'returns true for some darkened choices' do
          expect(@sheet.marked?(0,0)).to be_truthy
          expect(@sheet.marked?(1,1)).to be_truthy
          expect(@sheet.marked?(2,2)).to be_truthy
        end

        it 'return false for some blank choices' do
          expect(@sheet.marked?(0,1)).to be_falsy
          expect(@sheet.marked?(1,0)).to be_falsy
          expect(@sheet.marked?(2,3)).to be_falsy
        end

        it 'writes out markedness' do
          mf = File.open('spec/out/marked.txt', 'w')
          120.times do |q|
            x = 5.times.collect do |c|
              @sheet.marked?(q,c) ? '1' : '0'
            end
            mf.puts x.join(' ')
          end
          mf.close
        end
      end

      describe '#mark_array' do
        it 'should return an array of marked choices for each of the first 5 questions' do
          @sheet.mark_array(5).should == [[0], [1], [2], [3], [4]]
        end

        it 'should return an array of marked choices for the specified question set' do
          @sheet.mark_array([0, 1, 13, 16, 31, 104, 21]).should == [[0], [1], [3,4], [2], [1], [], [0,1,2,3,4]]
        end

        it 'should return an array of @grid.max_questions length if called without arguments' do
          @sheet.mark_array.length.should == 120
        end
      end

      describe '#mark_logical_array' do
        it 'should return an array of booleans for each of the first questions' do
          @sheet.mark_logical_array(5).should == [
            [true, false, false, false, false],
            [false, true, false, false, false],
            [false, false, true, false, false],
            [false, false, false, true, false],
            [false, false, false, false, true],
          ]
        end
      end

      describe 'barcodes' do
        it 'should read the bit string as all ones' do
          @sheet.barcode_string.should == '1111111111111111111111111111111111111111'
          @sheet.barcode.should == 1099511627775
        end

        it 'should read another bit string' do
          barcode_string = '0000000000000000000000000010000110100000'
          s2 = SheetOMR.new('spec/samples/sample02.jpg', [5]*100)
          s2.barcode_string.should == barcode_string
          s2.barcode.should == 8608
        end

        it 'should read the 666 bit string' do
          sh = sample_img 'code666'
          s2 = SheetOMR.new sh.filename, [5]*100, sh.grid_file
          s2.barcode.should == sh.barcode_int
        end
      end

    end

    context 'marking a problematic sheet' do
      let(:sheet) { SheetOMR.new 'spec/samples/out-1.jpg', [5]*100, 'spec/samples/grid.yml' }

      it 'highlights marked cells and outline correct responses' do
        sheet.cross_marked
        sheet.outline [[0,1,2,3,4]] * 100
        sheet.write 'spec/out/marks_and_outs.jpg'
      end

      it 'highlights the barcode' do
        sheet.highlight_barcode
        sheet.write 'spec/out/barcode.jpg'
      end
    end

    context 'systematic tests' do
      let(:bila)  { 'CCEBEBCEEACCDCABDBEBCADEADDCCCACCACDBBDAECDDABDEEBCEEDCBAAADEEEEDCADEABCBDECCCCDDDCABBECAADADBBEEABA'.split '' }
      let(:bila0) { SheetOMR.new 'spec/samples/syst/bila0.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:bila1) { SheetOMR.new 'spec/samples/syst/bila1.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:bila2) { SheetOMR.new 'spec/samples/syst/bila2.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:bila3) { SheetOMR.new 'spec/samples/syst/bila3.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:bila4) { SheetOMR.new 'spec/samples/syst/bila4.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:dald)  { 'DDDBECAAADBAEEEAEEEBAACAEDBDECDBDCDCDDEDCCDCDBDCADEEDBCCBEBBAADDCDBBECBBBDEABADABADADBABAEABACBDADDA'.split '' }
      let(:dald0) { SheetOMR.new 'spec/samples/syst/dald0.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:dald1) { SheetOMR.new 'spec/samples/syst/dald1.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:dald2) { SheetOMR.new 'spec/samples/syst/dald2.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:dald3) { SheetOMR.new 'spec/samples/syst/dald3.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:dald4) { SheetOMR.new 'spec/samples/syst/dald4.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:cost)  { 'ABBDDBAEAEBAADEAAECBCDBBDABABADEECCACBCAEDDAEBEABBCDABECAACEEEBADECBBEAADBBBEABDAEBDEEABBABEBEDDAEEC'.split '' }
      let(:cost0) { SheetOMR.new 'spec/samples/syst/cost0.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:cost1) { SheetOMR.new 'spec/samples/syst/cost1.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:cost2) { SheetOMR.new 'spec/samples/syst/cost2.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:cost3) { SheetOMR.new 'spec/samples/syst/cost3.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:cost4) { SheetOMR.new 'spec/samples/syst/cost4.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:bone)  { 'CECBBABAECADEDCACBBDEECBADBECDCEDECABCAADCBDEDACAEEDCCADBEDCEBCCBBDCCACDEDDAAECEBDBADCBAAEBAEDABCBDC'.split '' }
      let(:bone0) { SheetOMR.new 'spec/samples/syst/bone0.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:bone1) { SheetOMR.new 'spec/samples/syst/bone1.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:bone2) { SheetOMR.new 'spec/samples/syst/bone2.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:barr)  { 'ACECAAADDBCECCCDBEBECDEDAECEDDEEDCDEADDCCBCCCBBEACBCAEDEEDDDABBBBABEBDCEADEEDEBCBADBCEDCDBACEBCBDCDA'.split '' }
      let(:barr0) { SheetOMR.new 'spec/samples/syst/barr0.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:barr1) { SheetOMR.new 'spec/samples/syst/barr1.jpg', [5]*100,  'spec/samples/grid.yml'}
      let(:barr2) { SheetOMR.new 'spec/samples/syst/barr2.jpg', [5]*100,  'spec/samples/grid.yml'}

      it 'checks bila' do
        expect(bila0.mark_char_array.flatten).to eq(bila)
        expect(bila1.mark_char_array.flatten).to eq(bila)
        expect(bila2.mark_char_array.flatten).to eq(bila)
        expect(bila3.mark_char_array.flatten).to eq(bila)
        expect(bila4.mark_char_array.flatten).to eq(bila)
      end

      it 'checks dald' do
        expect(dald0.mark_char_array.flatten).to eq(dald)
        expect(dald1.mark_char_array.flatten).to eq(dald)
        expect(dald2.mark_char_array.flatten).to eq(dald)
        expect(dald3.mark_char_array.flatten).to eq(dald)
        expect(dald4.mark_char_array.flatten).to eq(dald)
      end

      it 'checks cost' do
        expect(cost0.mark_char_array.flatten).to eq(cost)
        expect(cost1.mark_char_array.flatten).to eq(cost)
        expect(cost2.mark_char_array.flatten).to eq(cost)
        expect(cost3.mark_char_array.flatten).to eq(cost)
        expect(cost4.mark_char_array.flatten).to eq(cost)
      end

      it 'checks bone' do
        expect(bone0.mark_char_array.flatten).to eq(bone)
        expect(bone1.mark_char_array.flatten).to eq(bone)
        expect(bone2.mark_char_array.flatten).to eq(bone)
      end

      it 'checks barr' do
        expect(barr0.mark_char_array.flatten).to eq(barr)
        expect(barr1.mark_char_array.flatten).to eq(barr)
        expect(barr2.mark_char_array.flatten).to eq(barr)
      end

    end

    # context "multi-page pdf" do
    #   before(:all) do
    #     @mlist = MimageList.new('spec/samples/two_pages.pdf')
    #   end
    #
    #   describe "reading the codes" do
    #     it "should read the right code for the first page" do
    #       s = SheetOMR.new(@mlist[0], Grid.new)
    #       s.code.should == 18446744073709551615
    #     end
    #     it "should read the right code for the second page" do
    #       s = SheetOMR.new(@mlist[1], Grid.new)
    #       s.code.should == 283764283738
    #     end
    #   end
    #
    #   describe "getting the answers" do
    #     it "should read the correct choices for the first page" do
    #       s = SheetOMR.new(@mlist[0], Grid.new)
    #       s.marked?( 0, 0).should be_truthy
    #       s.marked?( 0, 1).should be_falsy
    #       s.marked?(15, 3).should be_falsy
    #       s.marked?(15, 4).should be_truthy
    #     end
    #
    #     it "should read the correct choices for the second page" do
    #       s = SheetOMR.new(@mlist[1], Grid.new)
    #       s.mark_array(15).should == [[0], [1], [2], [3], [4], [0], [1], [2, 3], [4], [1, 2, 3], [0], [1], [2], [3], [4]]
    #     end
    #   end
    # end
  end
end

