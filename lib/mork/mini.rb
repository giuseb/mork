require 'narray'
require 'mini_magick'

module Mork
  class Mini
    def initialize(fname)
      @mini = MiniMagick::Image.open fname
      f = IO.read "|convert #{fname} gray:-"
      @pixels = NArray[f.unpack 'C*'].reshape width, height
    end
    
    def height
      @mini[:height]
    end
    
    def width
      @mini[:width]
    end
    
    def length
      @pixels.length
    end
    
    def pix
      @pixels
    end
    
    def dark_centroid
      xp = @pixels.sum(1).to_a
      yp = @pixels.sum(0).to_a
      # find the intensity trough
      ctr_x = xp.find_index(xp.min)
      ctr_y = yp.find_index(yp.min)
      return ctr_x, ctr_y
    end
    
    
  end
end

# @binf = "#{rand(36**80).to_s(36)}.gray"
# @mini.write @binf
