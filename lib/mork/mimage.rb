require 'mork/npatch'
require 'mork/magicko'

module Mork
  # The class Mimage processes the image.
  # Note that Mimage is NOT intended as public API, it should only be called by SheetOMR
  class Mimage
    attr_reader :rm

    def initialize(path, nitems, grom)
      @mack   = Magicko.new path
      @nitems = nitems
      @grom   = grom.set_page_size @mack.width, @mack.height
      @rm     = {} # registration mark centers
      @valid = register
    end

    def valid?
      @valid
    end

    def status
      {
        tl: @rm[:tl][:status],
        tr: @rm[:tr][:status],
        br: @rm[:br][:status],
        bl: @rm[:bl][:status]
      }
    end

    def marked?(q,c)
      shade_of(q,c) < choice_threshold
    end

    def barcode_bit?(i)
      reg_pixels.average(@grom.barcode_bit_area i+1) < barcode_threshold
    end

    def outline(cells)
      return if cells.empty?
      @mack.outline coordinates_of(cells)
    end

    # highlight_cells(cells, roundedness)
    #
    # partially transparent yellow on top of choice cells
    def highlight_cells(cells)
      return if cells.empty?
      @mack.highlight_cells coordinates_of(cells)
    end

    def highlight_all_choices
      cells = (0...@grom.max_questions).collect { |i| (0...@grom.max_choices_per_question).to_a }
      highlight_cells cells
    end

    def highlight_barcode(bitstring)
      @mack.highlight_rect @grom.barcode_bit_areas bitstring
    end

    def highlight_rm_centers
      each_corner { |c| @mack.plus @rm[c][:x], @rm[c][:y], 20 }
    end

    def highlight_rm_areas
      each_corner { |c| @mack.highlight_area @grom.rm_crop_area(c) }
    end

    def cross(cells)
      return if cells.empty?
      cells = [cells] if cells.is_a? Hash
      @mack.cross coordinates_of(cells)
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
    def each_corner
      [:tl, :tr, :br, :bl].each { |c| yield c }
    end

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

    # TODO: 0.75 should be a parameter
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

    def reg_pixels
      @reg_pixels ||= NPatch.new @mack.registered_bytes(@rm), @mack.width, @mack.height
    end

    def coordinates_of(cells)
      cells.collect.each_with_index do |q, i|
        q.collect { |c| @grom.choice_cell_area(i, c) }
      end.flatten
    end

    # find the XY coordinates of the 4 registration marks,
    # plus the stdev of the search area as quality control
    def register
      each_corner { |c| @rm[c] = rm_centroid_on c }
      # puts "TL: #{@rm[:tl].inspect}"
      # puts "TR: #{@rm[:tr].inspect}"
      # puts "BR: #{@rm[:br].inspect}"
      # puts "BL: #{@rm[:bl].inspect}"
      @rm.all? { |k,v| v[:status] == :ok }
    end

    # returns the centroid of the dark region within the given area
    # in the XY coordinates of the entire image
    def rm_centroid_on(corner)
      c = @grom.rm_crop_area(corner)
      p = @mack.rm_patch(c, @grom.rm_blur, @grom.rm_dilate)
      # puts "REG #{@grom.rm_blur} - #{@grom.rm_dilate} - C #{c.inspect}"
      n = NPatch.new(p, c.w, c.h)
      cx, cy, sd = n.centroid
      st = (cx < 2) or (cy < 2) or (cy > c.h-2) or (cx > c.w-2)
      status = st ? :edgy : :ok
      return {x: cx+c.x, y: cy+c.y, sd: sd, status: status}
    end
  end
end

# def corner
#   @corner_size ||= @grom.cell_corner_size
# end

# 1000.times do |i|
#   @rmsa[corner] = @grom.rm_search_area(corner, i)
#   # puts "================================================================"
#   # puts "Corner #{corner} - Iteration #{i} - Coo #{@rmsa[corner].inspect}"
#   cx, cy = raw_pixels.dark_centroid @rmsa[corner]
#   if cx.nil?
#     status = :no_contrast
#   elsif (cx < @grom.rm_edgy_x) or
#         (cy < @grom.rm_edgy_y) or
#         (cy > @rmsa[corner][:h] - @grom.rm_edgy_y) or
#         (cx > @rmsa[corner][:w] - @grom.rm_edgy_x)
#     status = :edgy
#   else
#     return {status: :ok, x: cx + @rmsa[corner][:x], y: cy + @rmsa[corner][:y]}
#   end
#   return {status: status, x: nil, y: nil} if @rmsa[corner][:w] > @grom.rm_max_search_area_side
# end

# TAKE OUT
# def highlight_reg_area
#   @mack.highlight_rect [@rmsa[:tl], @rmsa[:tr], @rmsa[:br], @rmsa[:bl]]
#   return unless valid?
#   @mack.join [@rm[:tl], @rm[:tr], @rm[:br], @rm[:bl]]
# end

# def raw_pixels
#   @mack.raw_patch
# end

