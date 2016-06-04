require 'mork/grid_omr'
require 'mork/mimage'
require 'mork/mimage_list'

module Mork
  # Optical mark recognition of a response sheet that was: 1) generated
  # with SheetPDF, 2) printed on plain paper, 3) filled out by a responder,
  # and 4) acquired as a image file.
  #
  # The sheet is automatically registered upon object creation, after which it
  # is possible to perform queries, as well as save a copy of the scanned
  # image with various overlays superimposed, highlighting the expected correc
  # choices, the actually marked ones, etc.
  class SheetOMR
    # @param path [String] the required path/filename to the saved image
    #   (.jpg, .jpeg, .png, or .pdf)
    # @param choices [Fixnum, Array] the questions/choices we want scored, as
    #   an optional named argument. Scoring is done on all available questions,
    #   if the argument is omitted, on the first N questions, If an integer
    #   is passed, or on the indicated questions, if the argument is an array.
    # @param layout [String, Hash] the sheet description. Use a string to
    #   specify the path/filename of a YAML file containing the parameters,
    #   or directly a hash of parameters. See the README file for a full listing
    #   of the available parameters.
    def initialize(path, choices: nil, layout: nil)
      raise IOError, "File '#{path}' not found" unless File.exists? path
      @grom   = GridOMR.new layout
      @nitems = case choices
                when nil
                  [@grom.max_choices_per_question] * @grom.max_questions
                when Fixnum
                  [@grom.max_choices_per_question] * choices
                when Array
                  choices
                end
      @mim    = Mimage.new path, @nitems, @grom
    end

    # True if sheet registration completed successfully
    #
    # @return [Boolean]
    def valid?
      @mim.valid?
    end

    # Registration status for each of the four corners
    #
    # @return [Hash] { tl: Symbol, tr: Symbol, br: Symbol, bl: Symbol } where
    #   symbol is either `:ok` or `:edgy`, meaning that the centroid was found
    #   to be too close to the edge of the search area to be considered reliable
    def status
      @mim.status
    end

    # Sheet barcode as an integer
    #
    # @return [Fixnum]
    def barcode
      return if not_registered
      barcode_string.to_i(2)
    end

    # Sheet barcode as a binary-like string
    #
    # @return [String] a string of 0s and 1s; the string is `barcode_bits`
    #   bits long, with most significant bits to the left
    def barcode_string
      return if not_registered
      cs = @grom.barcode_bits.times.inject("") { |c, v| c << barcode_bit_string(v) }
      cs.reverse
    end

    # True if the specified question/choice cell has been darkened
    #
    # @param question [Fixnum] the question number, zero-based
    # @param choice [Fixnum] the choice number, zero-based
    # @return [Boolean]
    def marked?(question, choice)
      return if not_registered
      @mim.marked? question, choice
    end

    # Array of arrays of marked choices.
    #
    # @param questions [Fixnum, Range, or Array] look for the first n questions
    #   If the argument is omitted, all available choices are evaluated.
    # @return [Array] The list of marked choices as an array (one element per
    #   question) of arrays (the indices of all marked choices for the question)
    def mark_array(questions = nil)
      return if not_registered
      # byebug
      question_range(questions).collect do |q|
        [].tap do |cho|
          (0...@grom.max_choices_per_question).each do |c|
            cho << c if marked?(q, c)
          end
        end
      end
    end

    # Array of arrays of the characters corresponding to marked choices.
    # At this time, only the latin sequence 'A, B, C...' is supported.
    #
    # @param questions [Fixnum, Range, Array] same as for `mark_array`
    # @return [Array] The list of marked choices as an array (one element per
    #   question) of arrays (the indices of all marked choices for the question)
    def mark_char_array(questions = nil)
      return if not_registered
      question_range(questions).collect do |q|
        [].tap do |cho|
          (0...@grom.max_choices_per_question).each do |c|
            cho << (65+c).chr if marked?(q, c)
          end
        end
      end
    end

    # Array of logical arrays of marked choices
    #
    # @param [Fixnum, Range, Array]
    def mark_logical_array(r = nil)
      return if not_registered
      question_range(r).collect do |q|
        (0...@grom.max_choices_per_question).collect {|c| marked?(q, c)}
      end
    end

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


    def highlight_all_choices
      return if not_registered
      @mim.highlight_all_choices
    end

    def highlight_marked
      return if not_registered
      @mim.highlight_cells mark_array
    end

    def highlight_barcode
      return if not_registered
      @mim.highlight_barcode barcode_string
    end

    # writes out a copy of the source image after registration;
    # the output image will also contain any previously applied overlays.
    def write(fname)
      return if not_registered
      @mim.write(fname, true)
    end

    def write_out(fname)
      return if not_registered
      yield self
      @mim.write fname, true
    end

    def write_registration(fname)
      @mim.highlight_rm_areas
      @mim.highlight_rm_centers
      @mim.write fname, false
    end

    # ============================================================#
    private                                                       #
    # ============================================================#

    def barcode_bit_string(i)
      @mim.barcode_bit?(i) ? "1" : "0"
    end

    def question_range(r)
      # TODO: help text: although not API, people need to know this!
      if r.nil?
        (0...@nitems.length)
      elsif r.is_a? Fixnum
        (0...r)
      elsif r.is_a? Array
        r
      else
        raise "Invalid argument"
      end
    end

    def not_registered
      unless valid?
        puts "---=={ Unregistered image. Reason: '#{@mim.status.inspect}' }==---"
        true
      end
    end
  end
end


# # write_raw(output_path_file_name)
# #
# # writes out a copy of the source image before registration;
# # the output image will also contain any previously applied overlays
# # if the argument is omitted, the image is created in-place,
# # i.e. the original source image is overwritten.
# def write_raw(fname=nil)
#   @mim.write(fname, false)
# end
