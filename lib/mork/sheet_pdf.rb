require 'mork/grid_pdf'
require 'prawn'

module Mork
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
      stroke do
        content.length.times do |q|
          fill_color "000000"
          text_box "#{q+1}", at: @grip.qnum_xy(q),
                             width: @grip.qnum_width,
                             align: :right,
                             size: @grip.item_font_size
          stroke_color "ff0000"
          font_size @grip.item_font_size
          content[q].times do |c|
            a = @grip.choice_cell_area q, c
            rounded_rectangle a[:p], a[:w], a[:h], [a[:h], a[:w]].min / 2
            fill_color "ff0000"
            text_box (65+c).chr, at: @grip.choice_letter_xy(q, c)
          end
        end
      end
    end
  end
end

# def control(content)
#   font_size @grip.control_size do
#     text_box content[:string], at: @grip.control_xy,
#                             width: @grip.control_width,
#                             align: :right
#     stroke do
#       stroke_color "ff0000"
#       # dark
#       a = @grip.ctrl_area_dark
#       rounded_rectangle a[:p], a[:w], a[:h], [a[:h], a[:w]].min / 2
#       fill_color "ff0000"
#       draw_text content[:labels][0], at: @grip.dark_control_letter_xy
#       # light
#       a = @grip.ctrl_area_light
#       rounded_rectangle a[:p], a[:w], a[:h], [a[:h], a[:w]].min / 2
#       fill_color "ff0000"
#       draw_text content[:labels][1], at: @grip.light_control_letter_xy
#
#     end
#   end
# end
#
