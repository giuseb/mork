require 'spec_helper'

module Mork
  describe Mimage do
    let(:qna) { [5] * 100 }
    context 'problematic sheets' do
      let(:mim)  { Mimage.new 'spec/samples/out-1.jpg', qna, GridOMR.new('spec/samples/grid.yml')  }
      let(:bila) { Mimage.new 'spec/samples/syst/bila0.jpg', qna, GridOMR.new('spec/samples/grid.yml') }
      
      xit 'writes all cell values to a text file' do
        d=Dir['spec/samples/syst/*.jpg']
        d.each do |f|
          fn = File.basename f, '.jpg'
          m = Mimage.new "spec/samples/syst/#{fn}.jpg", qna, GridOMR.new('spec/samples/grid.yml')
          puts fn
          File.open("spec/samples/syst/#{fn}.txt",'w') do |f|
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
    
    context 'Old specs' do
      let(:sgi) { sample_img 'sample-gray' }
      let(:sg)  { Mimage.new sgi.filename, qna, GridOMR.new(sgi.grid_file) }
    
      describe 'basics' do
        it 'returns the width' do
          expect(sg.width).to eq sgi.width
        end
      
        it 'returns the height' do
          expect(sg.height).to eq sgi.height
        end
      
        it 'returns the pixels as an array' do
          expect(sg.send :raw_pixels).to be_a NPatch
        end
      
        it 'returns the correct number of pixels' do
          expect(sg.send(:raw_pixels).length).to eq sgi.width * sgi.height
        end

        it 'returns the stretched array' do
          expect(sg.send(:reg_pixels).length).to eq sgi.width * sgi.height
        end
      
        it 'raises an error if the file is not found' do
          expect { Mimage.new 'non_existing_file' }.to raise_error
        end
      end

      describe 'inspecting' do
        xit 'writes out average whiteness of choice cells' do
          qz = sample_img 'silvia'
          s = Mimage.new qz.filename, [5] * 5, GridOMR.new(qz.grid_file)
          File.open('spec/out/choices.txt', 'w') do |f|
            5.times do |q|
              t = (0..4).collect do |c|
                s.send(:shade_of, q, c).round
              end
              f.puts "#{q+1}: #{t.join(' ')}"
            end
          end
        end
      end
    end
  end
end