require 'spec_helper'
require 'fileutils'

module Mork
  describe SheetOMR do
    context 'catching source file problems' do
      describe 'trying to process a non existing file' do
        it 'throws a file-not-found error' do
          expect { SheetOMR.new 'non_existing_file.jpg'}.to raise_error Errno::ENOENT, 'No such file or directory'
        end
      end

      describe 'trying to process a corrupted file' do
        it 'throws an IO error' do
          fn = sample_img('corrupted-pdf').image_path
          expect { SheetOMR.new fn}.to raise_error(IOError, 'Invalid image. File may have been damaged')
        end
      end
    end

    context 'using John Doe’s reference sheet' do
      let(:img) { sample_img 'jdoe1' }
      let(:fn)  { File.basename(img.image_path) }
      let(:omr) { SheetOMR.new img.image_path, layout: img.grid_path }

      context 'object creation' do
        describe '#new' do
          it 'creates a SheetOMR object' do
            expect(omr).to be_a SheetOMR
          end

          it 'registers the image correctly' do
            expect(omr.valid?).to be_truthy
          end
        end
      end

      context 'querying and modifying the object' do
        describe '#status' do
          it 'returns the valid (:ok) registration status for each corner' do
            expect(omr.status).to eq({ tl: :ok, tr: :ok, br: :ok, bl: :ok })
          end
        end

        describe '#set_choices' do
          it 'returns true if all goes well' do
            expect(omr.set_choices([10])).to be_truthy
          end

          it 'raises an Argument error if the choices argument is invalid' do
            expect { omr.set_choices('a string').to raise_error ArgumentError }
          end
        end
      end

      context 'analyzing the barcode' do
        describe '#barcode' do
          it 'returns the integer form of the barcode' do
            expect(omr.barcode).to eq img.barcode_int
          end
        end

        describe '#barcode_string' do
          it 'returns the binary string version of the barcode' do
            expect(omr.barcode_string).to eq img.barcode_str
          end
        end
      end

      context 'analyzing response cells' do
        describe '#marked?' do
          it 'returns true if the given cell was marked, false otherwise' do
            expect(omr.marked?   0, 0).to be_truthy
            expect(omr.marked?   0, 1).to be_falsy
            expect(omr.marked? 119, 4).to be_truthy
            expect(omr.marked? 119, 3).to be_falsy
          end
        end

        describe '#marked_choices' do
          it 'returns an array of marked choices as position indexes' do
            expect(omr.marked_choices ).to eq standard_mark_array(24)
          end

          it 'returns marked choices only for existing choice cells' do
            omr.set_choices [5, 4, 3, 2, 1]
            expect(omr.marked_choices).to eq [[0], [1], [2], [], []]
          end
        end

        describe '#marked_letters' do
          it 'returns an array of characters for the marked choices' do
            charr = img.mark_chars.split('').map { |c| [c] }
            expect(omr.marked_letters).to eq charr
          end
        end
      end

      context 'creating overlays and saving resulting JPEGs' do
        it 'highlights registration' do
          omr.save_registration "spec/out/JD-registration.jpeg"
        end

        it 'highlights the barcode' do
          omr.overlay :highlight, :barcode
          omr.save "spec/out/JD-highlight-barcode.jpeg"
        end

        it 'highlights all requested choice cells' do
          omr.set_choices [5] * 32
          omr.overlay :highlight, :all
          omr.save "spec/out/JD-highlight-all.jpeg"
        end

        it 'highlights all possible choice cells' do
          omr.set_choices [5] * 30 # this will be ignored
          omr.overlay :highlight, :max
          omr.save "spec/out/JD-highlight-max.jpeg"
        end

        it 'highlights marked cells' do
          omr.overlay :highlight, :marked
          omr.save "spec/out/JD-highlight-marked.jpeg"
        end

        it 'highlights marked cells (as default overlay)' do
          omr.overlay :highlight
          omr.save "spec/out/JD-highlight-marked-def.jpeg"
        end

        it 'highlights arbitrary cells' do
          omr.overlay :highlight, [[1,2], [], [0,1,2,3,4], [3]]
          omr.save "spec/out/JD-highlight-some.jpeg"
        end

        it 'highlights and crosses marked cells' do
          omr.overlay :highlight
          omr.overlay :check
          omr.save "spec/out/JD-highlight-and-cross.jpeg"
        end

        it 'checks marked cells' do
          omr.overlay :check
          omr.save "spec/out/JD-check-marked.jpeg"
        end

        it 'outlines marked cells' do
          omr.overlay :outline
          omr.save "spec/out/JD-outline-marked.jpeg"
        end
      end

      context 'requesting invalid responses and choices' do
        it 'raises an ArgumentError if the maximum number of responses is exceeded' do
          one_too_many = [[0]] * 121
          expect { omr.overlay(:check, one_too_many)}.to raise_error(ArgumentError)
        end

        it 'raises an ArgumentError if the maximum number of choices is exceeded' do
          one_too_many = [[5]]
          expect { omr.overlay(:check, one_too_many)}.to raise_error(ArgumentError)
        end
      end
    end

    context 'systematic tests' do
      let(:bila)  { 'CCEBEBCEEACCDCABDBEBCADEADDCCCACCACDBBDAECDDABDEEBCEEDCBAAADEEEEDCADEABCBDECCCCDDDCABBECAADADBBEEABA'.split '' }
      let(:bila0) { SheetOMR.new 'spec/samples/syst/bila0.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:bila1) { SheetOMR.new 'spec/samples/syst/bila1.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:bila2) { SheetOMR.new 'spec/samples/syst/bila2.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:bila3) { SheetOMR.new 'spec/samples/syst/bila3.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:bila4) { SheetOMR.new 'spec/samples/syst/bila4.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:dald)  { 'DDDBECAAADBAEEEAEEEBAACAEDBDECDBDCDCDDEDCCDCDBDCADEEDBCCBEBBAADDCDBBECBBBDEABADABADADBABAEABACBDADDA'.split '' }
      let(:dald0) { SheetOMR.new 'spec/samples/syst/dald0.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:dald1) { SheetOMR.new 'spec/samples/syst/dald1.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:dald2) { SheetOMR.new 'spec/samples/syst/dald2.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:dald3) { SheetOMR.new 'spec/samples/syst/dald3.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:dald4) { SheetOMR.new 'spec/samples/syst/dald4.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:cost)  { 'ABBDDBAEAEBAADEAAECBCDBBDABABADEECCACBCAEDDAEBEABBCDABECAACEEEBADECBBEAADBBBEABDAEBDEEABBABEBEDDAEEC'.split '' }
      let(:cost0) { SheetOMR.new 'spec/samples/syst/cost0.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:cost1) { SheetOMR.new 'spec/samples/syst/cost1.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:cost2) { SheetOMR.new 'spec/samples/syst/cost2.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:cost3) { SheetOMR.new 'spec/samples/syst/cost3.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:cost4) { SheetOMR.new 'spec/samples/syst/cost4.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:bone)  { 'CECBBABAECADEDCACBBDEECBADBECDCEDECABCAADCBDEDACAEEDCCADBEDCEBCCBBDCCACDEDDAAECEBDBADCBAAEBAEDABCBDC'.split '' }
      let(:bone0) { SheetOMR.new 'spec/samples/syst/bone0.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:bone1) { SheetOMR.new 'spec/samples/syst/bone1.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:bone2) { SheetOMR.new 'spec/samples/syst/bone2.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:barr)  { 'ACECAAADDBCECCCDBEBECDEDAECEDDEEDCDEADDCCBCCCBBEACBCAEDEEDDDABBBBABEBDCEADEEDEBCBADBCEDCDBACEBCBDCDA'.split '' }
      let(:barr0) { SheetOMR.new 'spec/samples/syst/barr0.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:barr1) { SheetOMR.new 'spec/samples/syst/barr1.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}
      let(:barr2) { SheetOMR.new 'spec/samples/syst/barr2.jpg', choices: [5]*100, layout: 'spec/samples/syst/layout.yml'}

      it 'checks bila' do
        expect(bila0.marked_letters.flatten).to eq(bila)
        expect(bila1.marked_letters.flatten).to eq(bila)
        expect(bila2.marked_letters.flatten).to eq(bila)
        expect(bila3.marked_letters.flatten).to eq(bila)
        expect(bila4.marked_letters.flatten).to eq(bila)
      end

      it 'checks dald' do
        expect(dald0.marked_letters.flatten).to eq(dald)
        expect(dald1.marked_letters.flatten).to eq(dald)
        expect(dald2.marked_letters.flatten).to eq(dald)
        expect(dald3.marked_letters.flatten).to eq(dald)
        expect(dald4.marked_letters.flatten).to eq(dald)
      end

      it 'checks cost' do
        expect(cost0.marked_letters.flatten).to eq(cost)
        expect(cost1.marked_letters.flatten).to eq(cost)
        expect(cost2.marked_letters.flatten).to eq(cost)
        expect(cost3.marked_letters.flatten).to eq(cost)
      end

      it 'fails to register cost4 because the BR corner is too far' do
        expect(cost4.status).to eq({tl: :ok, tr: :ok, br: :edgy, bl: :ok})
      end

      it 'checks bone' do
        expect(bone0.marked_letters.flatten).to eq(bone)
        expect(bone1.marked_letters.flatten).to eq(bone)
        expect(bone2.marked_letters.flatten).to eq(bone)
      end

      it 'checks barr' do
        expect(barr0.marked_letters.flatten).to eq(barr)
        expect(barr1.marked_letters.flatten).to eq(barr)
        expect(barr2.marked_letters.flatten).to eq(barr)
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


# it 'writes out markedness' do
#   mf = File.open('spec/out/text/marked.txt', 'w')
#   img.nitems.times do |q|
#     x = 5.times.map do |c|
#       omr.marked?(q,c) ? '1' : '0'
#     end
#     mf.puts x.join(' ')
#   end
#   mf.close
# end
