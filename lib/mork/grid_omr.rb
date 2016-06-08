require 'mork/grid'
require 'mork/coord'

module Mork
  # @private
  class GridOMR < Grid
    def initialize(options=nil)
      super options
    end

    def set_page_size(width, height)
      @px = width.to_f
      @py = height.to_f
      self
    end

    def barcode_areas(bits)
      [].tap do |areas|
        bits.each_with_index do |b, i|
          areas << barcode_bit_area(i+1) if b
        end
      end
    end

    # ===========================================
    # = Returning Coord sets for area locations =
    # ===========================================
    def choice_cell_area(q, c)
      coord cell_x(q,c), cell_y(q), cell_width, cell_height
    end

    def calibration_cell_areas
      rows.times.collect do |q|
        coord cal_cell_x, cell_y(q), cell_width, cell_height
      end
    end

    def barcode_bit_area(bit)
      coord barcode_bit_x(bit), barcode_y, barcode_width, barcode_height
    end

    def rm_crop_area(corner)
      coord rx(corner), ry(corner), reg_crop, reg_crop, ppu_x, ppu_y
    end

    def paper_white_area() barcode_bit_area(-1) end
    def ink_black_area()   barcode_bit_area( 0) end

    private

    def cx()    @px / reg_frame_width  end
    def cy()    @py / reg_frame_height end
    def ppu_x() @px / page_width       end
    def ppu_y() @py / page_height      end

    def coord(x, y, w, h, cX=cx, cY=cy)
      Coord.new w, h: h, x: x, y: y, cx: cX, cy: cY
    end

    # iterationless x registration
    def rx(corner)
      case corner
      when :tl; reg_off
      when :tr; page_width - reg_crop - reg_off
      when :br; page_width - reg_crop - reg_off
      when :bl; reg_off
      end
    end

    def ry(corner)
      case corner
      when :tl; reg_off
      when :tr; reg_off
      when :br; page_height - reg_crop - reg_off
      when :bl; page_height - reg_crop - reg_off
      end
    end
  end
end

# # the 4 values needed to locate a single registration mark
#
# def rm_search_area(corner, i)
#   {
#     x: (ppu_x * rmx(corner, i)).round,
#     y: (ppu_y * rmy(corner, i)).round,
#     w: (ppu_x * (reg_search + reg_radius * i)).round,
#     h: (ppu_y * (reg_search + reg_radius * i)).round
#   }
# end

# # finding the x position of the registration area based on iteration
# def rmx(corner, i)
#   case corner
#   when :tl; reg_off
#   when :tr; page_width - reg_search - reg_off - reg_radius * i
#   when :br; page_width - reg_search - reg_off - reg_radius * i
#   when :bl; reg_off
#   end
# end

# # finding the y position of the registration area based on iteration
# def rmy(corner, i)
#   case corner
#   when :tl; reg_off
#   when :tr; reg_off
#   when :br; page_height - reg_search - reg_off - reg_radius * i
#   when :bl; page_height - reg_search - reg_off - reg_radius * i
#   end
# end

# def rm_edgy_x()                (ppu_x * reg_radius).round + 5    end
# def rm_edgy_y()                (ppu_y * reg_radius).round + 5    end
# def rm_max_search_area_side()  (ppu_x * page_width / 4).round    end

# def cell_corner_size
#   d = choice_cell_area(0,0)
#   (d[:w]-d[:h]).abs
# end

# # GET RID OF THIS!
# def barcode_bit_areas(bitstring = '1' * barcode_bits)
#   areas = []
#   bitstring.reverse.each_char.with_index do |c, i|
#     areas << barcode_bit_area(i+1) if c=='1'
#   end
#   areas
# end
