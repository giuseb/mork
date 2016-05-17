require 'mini_magick'
require 'mork/npatch'

module Mork
  # The class Mimage manages the image. It is also a wrapper for the core image library
  # currently mini_magick. TODO: consider moving out the interaction with mini_magick.
  # Note that Mimage is NOT intended as public API, it should only be called by SheetOMR
  class Mimage
    def initialize(path, nitems, grom)
      @mack   = Magicko.new path
      @nitems = nitems
      @grom   = grom.set_page_size @mack.width, @mack.height
      @rm   = {} # registration mark centers
      @rmsa = {} # registration mark search area
      @valid = register
      @writing = nil
      @cmd = []
    end

    def valid?
      @valid
    end

    def status
      {
        tl: @rm[:tl][:status],
        tr: @rm[:tr][:status],
        br: @rm[:br][:status],
        bl: @rm[:bl][:status],
        write: @writing
      }
    end

    def marked?(q,c)
      shade_of(q,c) < choice_threshold
    end

    def barcode_bit?(i)
      reg_pixels.average(@grom.barcode_bit_area i+1) < barcode_threshold
    end

    # #!!! get rid of
    # def width
    #   @mack.width
    # end

    # #!!! get rid of
    # def height
    #   @mack.height
    # end

    # outline(cells, roundedness)
    #
    # draws on the Mimage a set of cell outlines
    # typically used to highlight the expected responses
    def outline(cells, roundedness=nil)
      return if cells.empty?
      @mack.outline coordinates_of cells, roundedness
    end

    # highlight_cells(cells, roundedness)
    #
    # partially transparent yellow on top of choice cells
    def highlight_cells(cells, roundedness=nil)
      return if cells.empty?
      @mack.highlight_cells coordinates_of(cells), roundedness
    end

    def highlight_all_choices
      cells = (0...@grom.max_questions).collect { |i| (0...@grom.max_choices_per_question).to_a }
      highlight_cells cells
    end

    def highlight_reg_area
      @mack.highlight_rect [@rmsa[:tl], @rmsa[:tr], @rmsa[:br], @rmsa[:bl]]
      return unless valid?
      @mack.join [@rm[:tl], @rm[:tr], @rm[:br], @rm[:bl]]
    end

    def highlight_barcode(bitstring)
      @mack.highlight_rect @grom.barcode_bit_areas bitstring
    end

    def cross(cells)
      return if cells.empty?
      cells = [cells] if cells.is_a? Hash
      @mack.cross coordinates_of cells, corner
    end

    # write the underlying MiniMagick::Image to disk;
    # if no file name is given, image is processed in-place;
    # if the 2nd arg is false, then stretching is not applied
    def write(fname=nil, reg=true)
      pp = reg ? @rm : nil
      @mack.write fname, pp
    end

    # ============================================================#
    private                                                       #
    # ============================================================#

    def shade_of(q,c)
      choice_cell_averages[q][c]
    end

    def choice_cell_averages
      @choice_cell_averages ||= begin
        @nitems.each_with_index.collect do |cho, q|
          cho.times.collect do |c|
            reg_pixels.average @grom.choice_cell_area(q, c)
          end
        end
      end
    end

    def choice_threshold
      @choice_threshold ||= (cal_cell_mean - darkest_cell_mean) * 0.75 + darkest_cell_mean
    end

    def barcode_threshold
      @barcode_threshold ||= (paper_white + ink_black) / 2
    end

    def cal_cell_mean
      @grom.calibration_cell_areas.collect { |c| reg_pixels.average c }.mean
    end

    def darkest_cell_mean
      choice_cell_averages.flatten.min
    end

    def ink_black
      reg_pixels.average @grom.ink_black_area
    end

    def paper_white
      reg_pixels.average @grom.paper_white_area
    end

    def raw_pixels
      @mack.raw_patch
    end

    def reg_pixels
      @mack.reg_patch @rm
    end

    def coordinates_of(cells)
      cells.collect.each_with_index do |q, i|
        q.collect { |c| @grom.choice_cell_area(i, c) }
      end.flatten
    end

    def corner
      @corner_size ||= @grom.cell_corner_size
    end

    def register
      # find the XY coordinates of the 4 registration marks
      @rm[:tl] = reg_centroid_on(:tl)
      # puts "TL: #{@rm[:tl][:status].inspect}"
      @rm[:tr] = reg_centroid_on(:tr)
      # puts "TR: #{@rm[:tr][:status].inspect}"
      @rm[:br] = reg_centroid_on(:br)
      # puts "BR: #{@rm[:br][:status].inspect}"
      @rm[:bl] = reg_centroid_on(:bl)
      # puts "BL: #{@rm[:bl][:status].inspect}"
      @rm.all? { |k,v| v[:status] == :ok }
    end

    # returns the centroid of the dark region within the given area
    # in the XY coordinates of the entire image
    def reg_centroid_on(corner)
      1000.times do |i|
        @rmsa[corner] = @grom.rm_search_area(corner, i)
        # puts "================================================================"
        # puts "Corner #{corner} - Iteration #{i} - Coo #{@rmsa[corner].inspect}"
        cx, cy = raw_pixels.dark_centroid @rmsa[corner]
        if cx.nil?
          status = :no_contrast
        elsif (cx < @grom.rm_edgy_x) or
              (cy < @grom.rm_edgy_y) or
              (cy > @rmsa[corner][:h] - @grom.rm_edgy_y) or
              (cx > @rmsa[corner][:w] - @grom.rm_edgy_x)
          status = :edgy
        else
          return {status: :ok, x: cx + @rmsa[corner][:x], y: cy + @rmsa[corner][:y]}
        end
        return {status: status, x: nil, y: nil} if @rmsa[corner][:w] > @grom.rm_max_search_area_side
      end
    end
  end
end
