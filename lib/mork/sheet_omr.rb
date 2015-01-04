require 'mork/grid_omr'
require 'mork/mimage'
require 'mork/mimage_list'

module Mork
  class SheetOMR
    def initialize(path, grom=nil)
      @grom = GridOMR.new grom
      @mim = Mimage.new path, @grom
    end
    
    def valid?
      @mim.valid?
    end
    
    def status
      @mim.status
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
    
    def cross(cells)
      return if not_registered
      raise "Invalid ‘cells’ argument" unless cells.kind_of? Array
      @mim.cross cells
    end
    
    def cross_marked
      return if not_registered
      @mim.cross mark_array
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
    
    def highlight_registration
      @mim.highlight_reg_area
    end

    # write(output_path_file_name)
    #
    # writes out a copy of the source image after registration;
    # the output image will also contain any previously applied overlays;
    # if the argument is omitted, the image is created in-place,
    # i.e. the original source image is overwritten.
    def write(fname=nil)
      return if not_registered
      @mim.write(fname)
    end
    
    # write_raw(output_path_file_name)
    #
    # writes out a copy of the source image before registration;
    # the output image will also contain any previously applied overlays
    # if the argument is omitted, the image is created in-place,
    # i.e. the original source image is overwritten.
    def write_raw(fname=nil)
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
      @barcode_threshold ||= (@mim.paper_white + ink_black) / 2
    end
    
    def choice_threshold
      @choice_threshold ||= (@mim.cal_cell_mean - ink_black) * 0.9 + ink_black
    end
    
    def ink_black
      @ink_black ||= @mim.ink_black
    end
    
    def not_registered
      unless valid?
        puts "---=={ Unregistered image. Reason: '#{@mim.status.inspect}' }==---"
        true
      end
    end
  end
end
