require 'narray'

module Mork
  # NPatch handles low-level computations on pixels by leveraging NArray
  class NPatch
    # NPatch.new(source, width, height) constructs an NPatch object
    # from the `source` linear array of bytes, to be reshaped as a
    # `width` by `height` matrix
    def initialize(source, width, height)
      @patch = NArray.byte(width, height)
      @patch[true] = source
      @width  = width
      @height = height
    end

    def average(c = nil)
      crop(c).mean
    end

    def stddev(c = nil)
      crop(c).stddev
    end

    def length
      # is this only going to be used for testing purposes?
      @patch.length
    end

    def dark_centroid(c = nil)
      p = crop c
      sufficient_contrast?(p) or return
      xp = p.sum(1).to_a
      yp = p.sum(0).to_a
      # find the intensity trough
      ctr_x = xp.find_index(xp.min)
      ctr_y = yp.find_index(yp.min)
      # puts "Centroid: #{ctr_x}, #{ctr_y} - MinX #{xp.min/xp.length}, MaxX #{xp.max/xp.length}, MinY #{yp.min/yp.length}, MaxY #{yp.max/yp.length}"
      return ctr_x, ctr_y
    end

    private

    def crop(c)
      c =  {x: 0, y: 0, w: @width, h: @height} if c.nil?
      x = c[:x]...c[:x]+c[:w]
      y = c[:y]...c[:y]+c[:h]
      p = NArray.float c[:w], c[:h]
      p[true,true] = @patch[x, y]
      p
    end

    def sufficient_contrast?(p)
      # puts "Contrast: #{p.stddev}"
      # tested with the few examples: spec/samples/rm0x.jpeg
      p.stddev > 20
    end
  end
end

