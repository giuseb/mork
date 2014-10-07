require 'spec_helper'

module Mork
  describe Mimage do
    let(:sgi) { sample_img 'sample-gray' }
    let(:sg)  { Mimage.new sgi.filename, GridOMR.new(sgi.grid_file) }
    
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
      it 'writes out average whiteness of choice cells' do
        qz = sample_img 'silvia'
        s = Mimage.new qz.filename, GridOMR.new(qz.grid_file)
        File.open('spec/out/choices.txt', 'w') do |f|
          120.times do |q|
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