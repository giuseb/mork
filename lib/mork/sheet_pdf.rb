require 'mork/grid_pdf'
require 'prawn'

module Mork
  
  #TODO: read the prawn manual, we should probably use views
  
  class SheetPDF < Prawn::Document
    def initialize(content, grip=GridPDF.new)
      @grip = case grip
              when String, Hash; GridPDF.new grip
              when Mork::GridPDF; grip
              else raise 'Invalid initialization parameter'
              end
      super my_page_params
      # @content should be an array of hashes, one per page;
      # convert to array if a single hash was passed
      @content = content.class == Hash ? [content] : content
      process
    end
    
    def save(fn)
      render_file fn
    end
    
    def to_pdf
      render
    end

    private

    def process
      # for each response sheet
      @content.each_with_index do |content, i|
        start_new_page if i>0
        fill_color "000000"
        stroke_color "000000"
        line_width 0.3
        registration_marks
        barcode content[:barcode]
        header content[:header]
        questions_and_choices content[:choices]
        calibration_cells
      end
    end
    
    def my_page_params
      {
        page_size: @grip.page_size,
        margin:    @grip.margins
      }
    end
    
    def registration_marks
      fill do
        @grip.reg_marks.each do |r|
          circle r[:p], r[:r]
        end
      end
    end
    
    def calibration_cells
      font_size @grip.item_font_size do
        stroke do
          stroke_color "ff0000"
          @grip.calibration_cell_areas.each_with_index do |a, i|
            rounded_rectangle a[:p], a[:w], a[:h], [a[:h], a[:w]].min / 2
            fill_color "ff0000"
            text_box 'X', at: @grip.calibration_letter_xy(i)
          end
        end
      end
    end
    
    def barcode(code)
      fill do
        # draw the dark calibration bar
        c = @grip.ink_black_area
        rectangle c[:p], c[:w], c[:h]
        # draw the bars corresponding to the code
        # least to most significant bit, left to right
        @grip.barcode_bit_areas_for(code).each do |c|
          rectangle c[:p], c[:w], c[:h]
        end
      end
    end
    
    def header(content)
      content.each do |k,v|
        font_size @grip.header_size(k) do
          if @grip.header_boxed?(k)
            bounding_box @grip.header_xy(k), width: @grip.header_width(k), height: @grip.header_height(k) do
              stroke_bounds
              bounding_box @grip.header_padding(k), width: @grip.header_width(k) do
                text v
              end
            end
          else
            text_box v, at: @grip.header_xy(k), width: @grip.header_width(k)
          end
        end
      end
    end

    def questions_and_choices(content)
      make_stamps
      stroke do
        a = @grip.choice_cell_area 0, 0
        rounded_rectangle a[:p], a[:w], a[:h], [a[:h], a[:w]].min / 2
        
        content.length.times do |q|
          fill_color "000000"
          text_box "#{q+1}", at: @grip.qnum_xy(q),
                             width: @grip.qnum_width,
                             align: :right,
                             size: @grip.item_font_size
          content[q].times do |c|
            stamp_cell q, c
            # a = @grip.choice_cell_area q, c
            # rounded_rectangle a[:p], a[:w], a[:h], [a[:h], a[:w]].min / 2
            # le = "st-#{(65+c).chr}"
            # stamp_at le, a[:p]
            # fill_color "ff0000"
            # text_box (65+c).chr, at: @grip.choice_letter_xy(q, c)
          end
        end
      end
    end
    
    def stamp_cell(q, c)
      stamp_at stamp_for(c), @grip.choice_cell_pos(q, c)
    end
    
    def make_stamps
      @grip.max_choices_per_question.times { |i| lettered_stamps i }
    end
    
    def lettered_stamps(i)
      create_stamp(stamp_for i) do
        font_size @grip.item_font_size
        stroke_rounded_rectangle [0,0], @grip.cell_width, @grip.cell_height, [@grip.cell_width, @grip.cell_height].min / 2
        draw_text letter_for(i), at: [7,-5]
      end
    end
    
    def stamp_for(c)
      "st-#{letter_for c}"
    end
    
    def letter_for(c)
      (65+c).chr
    end
  end
end
