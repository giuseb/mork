require 'narray'

module Mork
  # @private
  # NPatch handles low-level computations on pixels by leveraging NArray
  class NPatch
    # NPatch.new(source, width, height) constructs an NPatch object
    # from the `source` linear array of bytes, to be reshaped as a
    # `width` by `height` matrix
    def initialize(source, width, height)
      @patch = NArray.float(width, height)
      @patch[true] = source
    end

    def average(coord)
      @patch[coord.x_rng, coord.y_rng].mean
    end

    def stddev(coord)
      @patch[coord.x_rng, coord.y_rng].stddev
    end

    def centroid
      xp = @patch.sum(1).to_a
      yp = @patch.sum(0).to_a
      return xp.find_index(xp.min), yp.find_index(yp.min), @patch.stddev
    end
  end
end
