require 'spec_helper'

module Mork
  describe SheetOMR do
    context 'highlighting' do
      # since these specs change the @crop, they must be run in isolation
      # with the SheetOMR rebuilt each time, even though it is time consuming!
      let(:sheet) { SheetOMR.new 'spec/samples/sample_gray.jpg', 'spec/samples/layout.yml' }
      
      it 'highlights the registration areas and frame' do
        sheet.highlight_reg_area
        sheet.write_raw 'spec/out/reg_areas.jpg'
      end
      
      it 'should highlight all areas' do
        sheet.highlight_all
        sheet.write 'spec/out/all_highlights.jpg'
      end
      
      it 'should highlight marked cells and outline correct responses' do
        sheet.highlight_marked
        sheet.outline [[1],[1],[2],[2],[3,4],[],[0,1,2,3,4]]
        sheet.write 'spec/out/marked_highlights.jpg'
      end
      
      it 'highlights marked cells of a problematic one' do
        s = SheetOMR.new 'spec/samples/qzc013.jpg'
        s.highlight_marked
        s.write 'spec/out/problem.jpg'
      end
      
      it 'writes out average whiteness of choice cells' do
        s = SheetOMR.new 'spec/samples/qzc013.jpg'
        puts "Choice threshold: #{s.send :choice_threshold}"
        File.open('spec/out/choices.txt', 'w') do |f|
          120.times do |q|
            t = (0..4).collect do |c|
              s.send(:shade_of, q, c).round
            end
            f.puts "#{q+1}: #{t.join(' ')}"
          end
        end
        
        mf = File.open('spec/out/marked.txt',   'w')
        uf = File.open('spec/out/unmarked.txt', 'w')
        120.times do |q|
          5.times do |c|
            shade = s.send(:shade_of, q, c)
            s.marked?(q,c) ? mf.puts(shade) : uf.puts(shade)
          end
        end
        mf.close
        uf.close
      end
    end

    context 'marking a nicely printed and scanned sheet' do
      before(:all) do
        @sheet = SheetOMR.new('spec/samples/sample_gray.jpg', 'spec/samples/layout.yml')
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

        it 'writes out average whiteness of choice cells' do
          puts "Choice threshold: #{@sheet.send :choice_threshold}"
          File.open('spec/out/choices.txt', 'w') do |f|
            120.times do |q|
              t = (0..4).collect do |c|
                @sheet.send(:shade_of, q, c).round
              end
              f.puts "#{q+1}: #{t.join(' ')}"
            end
          end
          
          mf = File.open('spec/out/marked.txt',   'w')
          uf = File.open('spec/out/unmarked.txt', 'w')
          120.times do |q|
            5.times do |c|
              shade = @sheet.send(:shade_of, q, c)
              @sheet.marked?(q,c) ? mf.puts(shade) : uf.puts(shade)
            end
          end
          mf.close
          uf.close
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
          s2 = SheetOMR.new('spec/samples/sample02.jpg')
          s2.barcode_string.should == barcode_string
          s2.barcode.should == 8608
          s2.highlight_barcode
          s2.write 'spec/out/code_bits.jpg'
        end

        it 'should read the 666 bit string' do
          s2 = SheetOMR.new('spec/samples/sheet666.jpg')
          s2.barcode.should == 666666666666
          s2.highlight_barcode
          s2.write 'spec/out/code_bits666.jpg'
        end
      end
      
    end
    
    context 'a faded, b&w, distorted sheet' do
      it 'should return the correct barcode' do
        SheetOMR.new('spec/samples/sample03.jpg').barcode.should == 8608
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

