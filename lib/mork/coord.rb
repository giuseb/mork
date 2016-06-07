module Mork
  # The Coord class takes coordinates in the standard unit (e.g. mm)
  # and provides pixel-based coordinates useful for image manipulation
  class Coord
    attr_reader :x, :y, :w, :h

    def initialize(w, h: w, x: 0, y: 0, cx: 1, cy: cx)
      @x = (cx*x).round
      @y = (cy*y).round
      @w = (cx*w).round
      @h = (cy*h).round
    end

    def to_hash
      { w: @w, h: @h, x: @x, y: @y }
    end

    def print
      puts "X: #{@x}, Y: #{@y}, W: #{@w}, H: #{@h}"
    end

    def rect_points
      [@x, @y, @x+@w, @y+@h].join ' '
    end

    def choice_cell
      rness = [@h, @w].min / 2
      rect_points + " #{rness} #{rness}"
    end

    def cross1
      [@x+corner, @y+corner, @x+@w-corner, @y+@h-corner].join ' '
    end

    def cross2
      [@x+corner, @y+@h-corner, @x+@w-corner, @y+corner].join ' '
    end

    def cropper
      "#{@w}x#{@h}+#{@x}+#{@y}"
    end

    def x_rng
      @x...@x+@w
    end

    def y_rng
      @y...@y+@h
    end

    private

    def corner
      (@h - @w).abs
    end
  end
end
