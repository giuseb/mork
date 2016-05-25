require 'narray'

module Mork
  # NPatch handles low-level computations on pixels by leveraging NArray
  class NPatch
    # NPatch.new(source, width, height) constructs an NPatch object
    # from the `source` linear array of bytes, to be reshaped as a
    # `width` by `height` matrix
    def initialize(source, width, height)
      @patch = NArray.float(width, height)
      @patch[true] = source
      @width  = width
      @height = height
    end

    def average(c)
      @patch[c.x_rng, c.y_rng].mean
    end

    def stddev(c)
      @patch[c.x_rng, c.y_rng].stddev
    end

    def length
      # is this only going to be used for testing purposes?
      @patch.length
    end

    def centroid
      xp = @patch.sum(1).to_a
      yp = @patch.sum(0).to_a
      return xp.find_index(xp.min), yp.find_index(yp.min), @patch.stddev
    end

    private

    def sufficient_contrast?(p)
      # puts "Contrast: #{p.stddev}"
      # tested with the few examples: spec/samples/rm0x.jpeg
      p.stddev > 20
    end
  end
end

# def dark_centroid(c = nil)
#   p = crop c
#   sufficient_contrast?(p) or return
#   xp = p.sum(1).to_a
#   yp = p.sum(0).to_a
#   # find the intensity trough
#   ctr_x = xp.find_index(xp.min)
#   ctr_y = yp.find_index(yp.min)
#   # puts "Centroid: #{ctr_x}, #{ctr_y} - MinX #{xp.min/xp.length}, MaxX #{xp.max/xp.length}, MinY #{yp.min/yp.length}, MaxY #{yp.max/yp.length}"
#   return ctr_x, ctr_y
# end

# def crop(c)
#   raise "crop HELL" if c.nil?
#   p = NArray.float c.w, c.h
#   p[true,true] = @patch[c.x_rng, c.y_rng]
#   p
# end

