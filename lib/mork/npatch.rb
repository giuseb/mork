require 'narray'

module Mork
  # Handles low-level computations on a Mimage
  # Typically used on smaller patches
  class NPatch
    def initialize(mim)
      @mim = mim
      @width  = mim.width
      @height = mim.height
    end
    
    def average
      narr.mean
    end
    
    def dark_centroid
      sufficient_contrast? or return
      xp = patch.sum(1).to_a
      yp = patch.sum(0).to_a
      # find the intensity trough
      ctr_x = xp.find_index(xp.min)
      ctr_y = yp.find_index(yp.min)
      # return :edgy if edgy?(ctr_x, ctr_y)
      return ctr_x, ctr_y
    end
    
  private
    def patch
      @the_npatch ||= blurry_narr.reshape!(@width, @height)
    end
    
    def narr
      NArray[@mim.pixels]
    end
    
    def blurry_narr
      @blurry_narr ||= NArray[@mim.blur!(10,5).pixels]
    end

    def sufficient_contrast?
      # just a wild guess for now
      blurry_narr.stddev > 5000
    end
    
    def edgy?(x, y)
      tol = 5
      (x < tol) or (y < tol) or (y > @height - tol) or (x > @width - tol)
    end
  end
end