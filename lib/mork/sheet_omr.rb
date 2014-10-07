require 'mork/grid_omr'
require 'mork/mimage'
require 'mork/mimage_list'
# require 'mork/npatch'

module Mork
  class SheetOMR
    def initialize(path, grom=nil)
      @grom = GridOMR.new grom
      @mim = Mimage.new path, @grom
      @ok_reg = @mim.status
    end
    
    def valid?
      @ok_reg
    end
    
    # barcode
    # 
    # returns the sheet barcode as an integer
    def barcode
      return if not_registered
      barcode_string.to_i(2)
    end
    
    # barcode_string
    # 
    # returns the sheet barcode as a string of 0s and 1s. The string is barcode_bits
    # bits long, with most significant bits to the left
    def barcode_string
      return if not_registered
      cs = @grom.barcode_bits.times.inject("") { |c, v| c << barcode_bit_value(v) }
      cs.reverse
    end
    
    # marked?(question, choice)
    # 
    # returns true if the specified question/choice cell has been darkened
    # false otherwise
    def marked?(q, c)
      return if not_registered
      @mim.shade_of(q, c) < choice_threshold
    end
    
    # TODO: define method ‘mark’ to retrieve the choice array for a single item
    
    # mark_array(range)
    # 
    # returns an array of arrays of marked choices.
    # takes either a range of questions, an array of questions, or a fixnum,
    # in which case the choices for the first n questions will be returned.
    # if called without arguments, all available choices will be evaluated
    def mark_array(r = nil)
      return if not_registered
      question_range(r).collect do |q|
        cho = []
        (0...@grom.max_choices_per_question).each do |c|
          cho << c if marked?(q, c)
        end
        cho
      end
    end
    
    def mark_logical_array(r = nil)
      return if not_registered
      question_range(r).collect do |q|
        (0...@grom.max_choices_per_question).collect {|c| marked?(q, c)}
      end
    end
    
    # ================
    # = HIGHLIGHTING =
    # ================
    
    def outline(cells)
      return if not_registered
      raise "Invalid ‘cells’ argument" unless cells.kind_of? Array
      @mim.outline cells
    end
    
    def highlight_marked
      return if not_registered
      @mim.highlight_cells mark_array
    end
    
    def highlight_all_choices
      return if not_registered
      @mim.highlight_all_choices
    end
    
    def highlight_barcode
      return if not_registered
      @mim.highlight_barcode barcode_string
    end
    
    def highlight_reg_area
      @mim.highlight_reg_area
    end

    def write(fname)
      return if not_registered
      @mim.write(fname)
    end
    
    def write_raw(fname)
      @mim.write(fname, false)
    end
    
    # ============================================================#
    private                                                       #
    # ============================================================#
  

    def question_range(r)
      if r.nil?
        (0...@grom.max_questions)
      elsif r.is_a? Fixnum
        (0...r)
      elsif r.is_a? Array
        r
      else
        raise "Invalid argument"
      end
    end
    
    def barcode_bit_value(i)
      @mim.shade_of_barcode_bit(i) < barcode_threshold ? "1" : "0"
    end
    
    def barcode_threshold
      @barcode_threshold ||= (paper_white + ink_black) / 2
    end
    
    def choice_threshold
      @choice_threshold ||= (ccmeans.mean - ink_black) * 0.9 + ink_black
    end
    
    def ccmeans
      @calcmeans ||= @mim.cal_cell_means
    end
    
    def paper_white
      @paper_white ||= @mim.paper_white
    end
    
    def ink_black
      @ink_black ||= @mim.ink_black
    end
    
    def not_registered
      unless @ok_reg
        puts "---=={ Unregistered image. Reason: '#{@rm.inspect}' }==---"
        true
      end
    end
  end
end


# # ================
# # = Registration =
# # ================
#
# # this method uses a 'stretch' strategy, i.e. where the image after
# # registration has the same size in pixels as the original scanned file
# def register
#   # find the XY coordinates of the 4 registration marks
#   @rm   = {}
#   @rmsa = {}
#   @rm[:tl] = reg_centroid_on(:tl)
#   @rm[:tr] = reg_centroid_on(:tr)
#   @rm[:br] = reg_centroid_on(:br)
#   @rm[:bl] = reg_centroid_on(:bl)
#   # return the status
#   @rm.all? { |k,v| v[:status] == :ok }
# end
#
# # returns the centroid of the dark region within the given area
# # in the XY coordinates of the entire image
# def reg_centroid_on(corner)
#   1000.times do |i|
#     @rmsa[corner] = @grom.rm_search_area(corner, i)
#     cx, cy = raw_pixels.dark_centroid @rmsa[corner]
#     if cx.nil?
#       status = :insufficient_contrast
#     elsif (cx < @grom.rm_edgy_x) or
#           (cy < @grom.rm_edgy_y) or
#           (cy > @rmsa[corner][:h] - @grom.rm_edgy_y) or
#           (cx > @rmsa[corner][:w] - @grom.rm_edgy_x)
#       status = :edgy
#     else
#       return {status: :ok, x: cx + @rmsa[corner][:x], y: cy + @rmsa[corner][:y]}
#     end
#     return {status: status, x: nil, y: nil} if @rmsa[corner][:w] > @grom.rm_max_search_area_side
#   end
# end
# def raw_pixels
#   @raw_pixels ||= NPatch.new @mim.pixels, @mim.width, @mim.height
# end
#
# def reg_pixels
#   @reg_pixels ||= begin
#     crop = @mim.reg_pixels [
#       @rm[:tl][:x], @rm[:tl][:y],          0,          0,
#       @rm[:tr][:x], @rm[:tr][:y], @mim.width,          0,
#       @rm[:br][:x], @rm[:br][:y], @mim.width, @mim.height,
#       @rm[:bl][:x], @rm[:bl][:y],          0, @mim.height
#     ]
#     NPatch.new crop, @mim.width, @mim.height
#   end
# end
#
#
# def naverage(where)
#   @reg_pixels.average where
# end
