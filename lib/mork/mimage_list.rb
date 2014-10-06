# require 'RMagick'

module Mork
  # The class MimageList
  class MimageList
    def initialize(fname)
      raise "Initializing a MimageList requires a string" unless fname.class == String
      if File.extname(fname) == '.pdf'
        @images = Magick::ImageList.new(fname) { self.density = 200 }
      else
        @images = Magick::ImageList.new(fname)
      end
    end
    
    def shift
      Mimage.new @images.shift
    end
    
    def [] (i)
      # puts "I: #{i}"
      # puts @images[i].inspect
      Mimage.new @images[i]
    end
    
    def each
      @images.each do |i|
        yield Mimage.new i
      end
    end
  end
end