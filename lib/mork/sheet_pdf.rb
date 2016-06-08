require 'mork/grid_pdf'
require 'prawn'

module Mork

  # Generating response sheets as PDF files.
  # See the README file for usage
  class SheetPDF < Prawn::Document
    def initialize(content, layout=nil)
      @grip = case layout
              when NilClass; GridPDF.new
              when String, Hash; GridPDF.new layout
              when Mork::GridPDF; layout
              else raise ArgumentError, 'Invalid initialization parameter'
              end
      super my_page_params
      # @content should be an array of hashes, one per page;
      # convert to array if a single hash was passed
      @content = content.class == Hash ? [content] : content
      process
    end

    # Saving the PDF file to disk
    #
    # @param fname [String] the path/filename for the target PDF document
    def save(fname)
      render_file fname
    end

    # The PDF document as a string
    def to_pdf
      render
    end

    ###########################################################################
    private
    ###########################################################################

    def my_page_params
      {
        page_size: @grip.page_size,
        margin:    @grip.margins
      }
    end

    def process
      # for all sheets
      line_width 0.3
      font_size @grip.item_font_size
      create_stamps
      make_repeaters
      # for each response sheet
      @content.each_with_index do |content, i|
        start_new_page if i>0
        barcode content[:barcode]
        header content[:header]
        unless equal_choice_number?
          questions_and_choices ch_len[i]
        end
      end
    end

    def make_repeaters
      if equal_choice_number?
        repeat(:all) do
          questions_and_choices ch_len.first
        end
      end

      repeat(:all) do
        calibration_cells
        fill do
          @grip.reg_marks.each do |r|
            circle r[:p], r[:r]
          end
        end
      end
    end

    def calibration_cells
      @grip.calibration_cells_xy.each { |c| stamp_at 'X', c }
    end

    def barcode(code)
      # draw the dark calibration bar
      stamp_at 'barcode', @grip.ink_black_xy
      # draw the bars corresponding to the code
      # least to most significant bit, left to right
      @grip.barcode_xy_for(code).each { |c| stamp_at 'barcode', c }
    end

    def header(content)
      content.each do |k,v|
        font_size @grip.header_size(k) do
          align = @grip.header_align(k).nil?? :left : @grip.header_align(k).to_sym
          if @grip.header_boxed?(k)
            bounding_box @grip.header_xy(k), width: @grip.header_width(k), height: @grip.header_height(k) do
              stroke_bounds
              text_box v, at:    @grip.header_padding(k),
                          width: @grip.header_width(k)-@grip.header_padding(k)[0]*2,
                          align: align
            end
          else
            text_box v, at:     @grip.header_xy(k),
                        width:  @grip.header_width(k),
                        height: @grip.header_height(k),
                        align: align
          end
        end
      end
    end

    def questions_and_choices(n_ch)
      n_ch.each_with_index do |n, i|
        text_box "#{i+1}",
                 at: @grip.qnum_xy(i),
                 width: @grip.qnum_width,
                 height: @grip.height_of_cell,
                 align: :right,
                 valign: :center
        stamp_at "s#{n}", @grip.item_xy(i)
      end
    end

    def create_stamps
      create_choice_stamps
      create_stamp('X') do
        cell_stamp_content 'X', 0
      end
      create_stamp('barcode') do
        fill do
          rectangle [0,0], @grip.barcode_width, @grip.barcode_height
        end
      end
    end

    def create_choice_stamps
      ch_len.flatten.uniq.each do |t|
        create_stamp("s#{t}") do
          t.times do |i|
            cell_stamp_content letter_for(i), @grip.choice_spacing*i
          end
        end
      end
    end

    def cell_stamp_content(l, x)
      stroke_rounded_rectangle [x,0],
                               @grip.width_of_cell,
                               @grip.height_of_cell,
                               @grip.cround
      text_box l,
               at:     [x,0],
               width:  @grip.width_of_cell,
               height: @grip.height_of_cell,
               align:  :center,
               valign: :center
    end

    def equal_choice_number?
      return false unless ch_len.all? { |c| c.length == ch_len[0].length }
      ch_len[0].each_with_index do |c, i|
        return false unless ch_len.all? { |x| c == x[i] }
      end
      true
    end

    def ch_len
      @all_choice_lengths ||= @content.collect { |c| c[:choices] }
    end

    # Choices are labeled 'A', 'B', ...
    def letter_for(c)
      (65+c).chr
    end
  end
end
