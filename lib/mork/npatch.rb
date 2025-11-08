require 'numo/narray'

module Mork
  # @private
  # NPatch handles low-level computations on pixels by leveraging Numo::NArray
  class NPatch
    # NPatch.new(source, width, height) constructs an NPatch object
    # from the `source` linear array of bytes, to be reshaped as a
    # `width` by `height` matrix
    def initialize(source, width, height)
      # Numo::NArray uses row-major order, so we reshape and transpose
      @patch = Numo::SFloat.cast(source).reshape(height, width).transpose
    end

    def average(coord)
      @patch[coord.x_rng, coord.y_rng].mean
    end

    def stddev(coord)
      @patch[coord.x_rng, coord.y_rng].stddev
    end

    def centroid
      xp = @patch.sum(axis: 1).to_a
      yp = @patch.sum(axis: 0).to_a
      return xp.find_index(xp.min), yp.find_index(yp.min), @patch.stddev
    end
  end
end
