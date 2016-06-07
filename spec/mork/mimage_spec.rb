require 'spec_helper'

module Mork
  describe Mimage do
    let(:qna) { [5] * 100 }

    context 'John Doe' do
      let(:img) { sample_img 'jdoe1' }
      let(:fn)  { File.basename(img.image_path) }
      let(:mim) { Mimage.new img.image_path, [img.nchoices]*img.nitems, GridOMR.new(img.grid_path)  }
      describe 'basics' do
        it 'should be valid' do
          expect(mim.valid?).to be_truthy
        end

        it 'should return the correct regmark coordinates' do
          [:tl, :tr, :br, :bl].each do |corner|
            crn = mim.rm[corner]
            expect(crn[:x]).to be_within(2).of(img.send(corner)[0])
            expect(crn[:x]).to be_within(2).of(img.send(corner)[0])
          end
        end

        xit 'writes all cell values to a text file' do
          d=Dir['spec/samples/syst/*.jpg']
          d.each do |f|
            fname = File.basename f, '.jpg'
            m = Mimage.new "spec/samples/syst/#{fname}.jpg", qna, GridOMR.new('spec/samples/grid.yml')
            puts fname
            File.open("spec/out/text/#{fname}.txt",'w') do |f|
              f.puts "ink:#{m.send :ink_black}"
              f.puts "drk:#{m.send :darkest_cell_mean}"
              f.puts "pap:#{m.send :paper_white}"
              f.puts "cal:#{m.send :cal_cell_mean}"
              f.puts "cho:#{m.send :choice_threshold}"
              100.times do |q|
                5.times do |c|
                  f.puts m.send('choice_cell_averages')[q, c]
                end
              end
            end
          end
        end
      end
    end
  end
end

# it 'writes the registration highlights' do
#   mim.highlight_rm_centers
#   mim.highlight_rm_areas
#   mim.save "spec/out/registration/mim-#{fn}", false
# end
