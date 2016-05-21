module Mork
  class Coord
    attr_reader :x, :y, :w, :h

    def initialize(w, h=w, x=0, y=0, c=1)
      @x = (c*x).round
      @y = (c*y).round
      @w = (c*w).round
      @h = (c*h).round
    end

    def x_rng
      @x...@x+@w
    end

    def y_rng
      @y...@y+@h
    end
  end
end
