require 'mork/grid'

module Mork
  # GridPDF gets coordinates and measurements from a Grid and
  # provides SheetPDF with the properly computed values
  class GridPDF < Grid
    def initialize(options=nil)
      super options
    end
    
    def reg_marks
      r = reg_radius.mm
      [
        { p: [0,                  0                  ], r: r },
        { p: [0,                  reg_frame_height.mm], r: r },
        { p: [reg_frame_width.mm, reg_frame_height.mm], r: r },
        { p: [reg_frame_width.mm, 0                  ], r: r }
      ]
    end
    
    def barcode_width
      super.mm
    end
    
    def barcode_height
      super.mm
    end
    
    def barcode_xy_for(code)
      black = barcode_bits.times.reject { |x| (code>>x)[0]==0 }
      black.collect { |x| barcode_xy x+1 }
    end
    
    def ink_black_xy
      barcode_xy 0
    end
    
    def calibration_cells_xy
      rows.times.collect do |q|
        [(reg_frame_width-cell_spacing).mm, item_y(q).mm]
      end
    end
    
    # Coordinates at which to place item numbers
    def qnum_xy(q)
      [
        item_x(q).mm - qnum_width - qnum_margin,
        item_y(q).mm
      ]
    end
    
    def width_of_cell
      cell_width.mm
    end
    
    def height_of_cell
      cell_height.mm
    end
    
    def choice_spacing
      cell_spacing.mm
    end
    
    def item_xy(q)
      [item_x(q).mm, item_y(q).mm]
    end
    
    def cround
      @cround ||= [width_of_cell, height_of_cell].min / 2
    end

    def page_size()      [page_width.mm, page_height.mm]         end
    def margins()        reg_margin.mm                           end
    def qnum_margin()    @params[:items][:number_margin].to_f.mm end
    def qnum_width()     @params[:items][:number_width].to_f.mm  end
    def item_font_size() @params[:items][:font_size].to_f        end
    def header_width(k)  @params[:header][k][:width].to_f.mm     end
    def header_height(k) @params[:header][k][:height].to_f.mm    end
    def header_size(k)   @params[:header][k][:size].to_f         end
    def header_boxed?(k) @params[:header][k][:box] == true       end

    def header_xy(k)
      [
        @params[:header][k][:left].to_f.mm,
        (reg_frame_height - @params[:header][k][:top].to_f).mm
      ]
    end

    def header_padding(k)
      [
        1.mm,
        header_height(k) - 1.mm
      ]
    end

    private

    def item_y(q)
      reg_frame_height - cell_y(q)
    end

    def barcode_xy(i)
      [
        barcode_bit_x(i).mm,
        barcode_height
      ]
    end
    
    def barcode_area(i)
      {
        p: [barcode_bit_x(i).mm, (reg_frame_height - barcode_y).mm],
        w: barcode_width.mm,
        h: barcode_height.mm * 2
      }
    end
  end
end