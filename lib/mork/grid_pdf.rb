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
    
    def barcode_bit_areas_for(code)
      black = barcode_bits.times.reject { |x| (code>>x)[0]==0 }
      black.collect { |x| barcode_area x+1 }
    end
    
    def calibration_cell_areas
      rows.times.collect do |q|
        {
          p: [(reg_frame_width-cell_spacing).mm, (reg_frame_height - cell_y(q)).mm],
          w: cell_width.mm,
          h: cell_height.mm
        }
      end
    end
    
    # Coordinates at which to place calibration cell labels (usually an ‘X’)
    def calibration_letter_xy(q)
      [
        (reg_frame_width-cell_spacing).mm + 2.mm,
        item_text_y(q)
      ]
    end
    
    # Coordinates at which to place item numbers
    def qnum_xy(q)
      [
        cell_x(q, 0).mm - qnum_width - @params[:items][:number_margin].to_f.mm,
        item_text_y(q)
      ]
    end
    
    # Coordinates at which to place choice labels
    def choice_letter_xy(q, c)
      [
        cell_x(q, c).mm + 2.mm,
        item_text_y(q)
      ]
    end
    
    def choice_cell_area(q, c)
      {
        p: [cell_x(q, c).mm, (reg_frame_height - cell_y(q)).mm],
        w: cell_width.mm,
        h: cell_height.mm
      }
    end

    def page_size()      [page_width.mm, page_height.mm]        end
    def margins()        reg_margin.mm                          end
    def ink_black_area() barcode_area(0)                        end
    def qnum_width()     @params[:items][:number_width].to_f.mm end
    def item_font_size() @params[:items][:font_size].to_f       end
    def header_width(k)  @params[:header][k][:width].to_f.mm    end
    def header_height(k) @params[:header][k][:height].to_f.mm   end
    def header_size(k)   @params[:header][k][:size].to_f        end
    def header_boxed?(k) @params[:header][k][:box] == true      end

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
    
    def item_text_y(q)
      (reg_frame_height - cell_y(q) - cell_height/4).mm
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