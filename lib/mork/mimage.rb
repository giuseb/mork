require 'mork/npatch'
require 'mork/magicko'

module Mork
  # @private
  class Mimage
    attr_reader :rm
    attr_reader :choxq # choices per question

    def initialize(path, grom)
      @mack  = Magicko.new path
      @grom  = grom.set_page_size @mack.width, @mack.height
      @choxq = [grom.max_choices_per_question] * grom.max_questions
      @rm    = {} # registration mark centers
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

    def set_ch(cho)
      @choxq = cho
      # if set_ch is called more than once, discard memoization
      @marked_choices = @choice_mean_darkness = nil
    end

    def choice_mean_darkness
      @choice_mean_darkness ||= begin
        @choxq.map.with_index do |cho, q|
          cho.times.map do |c|
            reg_pixels.average @grom.choice_cell_area(q, c)
          end
        end
      end
    end

    def marked
      @marked_choices ||= begin
        choice_mean_darkness.map do |cho|
          [].tap do |choices|
            cho.map.with_index do |drk, c|
              choices << c if drk < choice_threshold
            end
          end
        end
      end
    end

    def barcode_bits
      @barcode_bits ||= begin
        @grom.barcode_bits.times.map do |b|
          reg_pixels.average(@grom.barcode_bit_area b+1) < barcode_threshold
        end
      end
    end

    def overlay(what, where)
      areas = case where
              when :barcode
                @grom.barcode_areas barcode_bits
              when :cal
                @grom.calibration_cell_areas
              when :marked
                choice_cell_areas marked
              when :all
                choice_cell_areas @choxq
              when :max
                @grom.choice_cell_areas
                # choice_cell_areas [@grom.max_choices_per_question] * @grom.max_questions
                # @grom.max_questions.times.map { |i| (0...@grom.max_choices_per_question).to_a }
              when Array
                choice_cell_areas where
              else
                raise ArgumentError, 'Invalid overlay argument “where”'
              end
      round = where != :barcode
      @mack.send what, areas, round
    end

    # write the underlying MiniMagick::Image to disk;
    # if no file name is given, image is processed in-place;
    # if the 2nd arg is false, then stretching is not applied
    def save(fname=nil, reg=true)
      pp = reg ? @rm : nil
      @mack.save fname, pp
    end

    def save_registration(fname)
      each_corner { |c| @mack.plus @rm[c][:x], @rm[c][:y], 30 }
      each_corner { |c| @mack.outline [@grom.rm_crop_area(c)], false }
      @mack.save fname, nil
    end

    # ============================================================#
    private                                                       #
    # ============================================================#

    def itemator(items=@choxq)
      items.map.with_index do |cho, q|
        if cho.is_a? Fixnum
          cho.times.map { |c| yield q, c }
        else
          cho.map { |c| yield q, c }
        end
      end
    end

    def choice_cell_areas(cells)
      itemator(cells) { |q,c| @grom.choice_cell_area q, c }.flatten
    end

    def each_corner
      [:tl, :tr, :br, :bl].each { |c| yield c }
    end

    def choice_threshold
      @choice_threshold ||= begin
        dcm = choice_mean_darkness.flatten.min
        (cal_cell_mean-dcm) * @grom.choice_threshold + dcm
      end
    end

    def cal_cell_mean
      m = @grom.calibration_cell_areas.collect { |c| reg_pixels.average c }
      m.inject(:+) / m.length.to_f
    end

    def barcode_threshold
      @barcode_threshold ||= (paper_white + ink_black) / 2
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

    # find the XY coordinates of the 4 registration marks,
    # plus the stdev of the search area as quality control
    def register
      each_corner { |c| @rm[c] = rm_centroid_on c }
      @rm.all? { |k,v| v[:status] == :ok }
    end

    # returns the centroid of the dark region within the given area
    # in the XY coordinates of the entire image
    def rm_centroid_on(corner)
      c = @grom.rm_crop_area(corner)
      p = @mack.rm_patch(c, @grom.rm_blur, @grom.rm_dilate)
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

# def outline(cells)
#   return if cells.empty?
#   @mack.outline coordinates_of(cells)
# end

# # highlight_cells(cells, roundedness)
# #
# # partially transparent yellow on top of choice cells
# def highlight_cells(cells)
#   return if cells.empty?
#   @mack.highlight_cells coordinates_of(cells)
# end

# def highlight_all_choices
#   cells = (0...@grom.max_questions).collect { |i| (0...@grom.max_choices_per_question).to_a }
#   highlight_cells cells
# end

# def highlight_barcode(bitstring)
#   @mack.highlight_rect @grom.barcode_bit_areas bitstring
# end

# def highlight_rm_centers
#   each_corner { |c| @mack.plus @rm[c][:x], @rm[c][:y], 20 }
# end

# def highlight_rm_areas
#   each_corner { |c| @mack.highlight_area @grom.rm_crop_area(c) }
# end

# def cross(cells)
#   return if cells.empty?
#   cells = [cells] if cells.is_a? Hash
#   @mack.cross coordinates_of(cells)
# end

# def barcode_bit?(i)
#   reg_pixels.average(@grom.barcode_bit_area i+1) < barcode_threshold
# end

# puts "TL: #{@rm[:tl].inspect}"
# puts "TR: #{@rm[:tr].inspect}"
# puts "BR: #{@rm[:br].inspect}"
# puts "BL: #{@rm[:bl].inspect}"

# puts "REG #{@grom.rm_blur} - #{@grom.rm_dilate} - C #{c.inspect}"

# def marked_int
#   marked.map do |q|
#     [].tap do |choices|
#       q.each_with_index do |choice, idx|
#         choices << idx if choice
#       end
#     end
#   end
# end

# def coordinates_of(cells)
#   cells.collect.each_with_index do |q, i|
#     q.collect { |c| @grom.choice_cell_area(i, c) }
#   end.flatten
# end

# def shade_of(q,c)
#   choice_mean_darkness[q][c]
# end

# def all_choice_cell_areas
#   choice_cell_areas(@choxq)
# end

