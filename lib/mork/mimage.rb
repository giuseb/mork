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
      # @choxq = [grom.max_choices_per_question] * grom.max_questions
      @choxq = [(0...@grom.max_choices_per_question).to_a] * grom.max_questions
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

    def set_ch(choxq)
      @choxq =  choxq.map { |ncho| (0...ncho).to_a }
      # if set_ch is called more than once, discard memoization
      @marked_choices = @choice_mean_darkness = nil
    end

    def choice_mean_darkness
      @choice_mean_darkness ||= begin
        itemator(@choxq) { |q,c| reg_pixels.average @grom.choice_cell_area(q, c) }
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
                @grom.choice_cell_areas.flatten
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

    def itemator(cells)
      cells.map.with_index do |cho, q|
        cho.map { |c| yield q, c }
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
