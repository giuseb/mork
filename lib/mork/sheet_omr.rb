require 'mork/grid_omr'
require 'mork/mimage'

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
    # @param layout [String, Hash] the sheet description. Send a hash of
    #   parameters or a string to specify the path/filename of a YAML file
    #   containing the parameters. See the README file for a full listing
    #   of the available parameters.
    def initialize(path, layout=nil)
      raise IOError, "File '#{path}' not found" unless File.exists? path
      grom = GridOMR.new layout
      @mim = Mimage.new path, grom
    end

    # True if sheet registration completed successfully
    #
    # @return [Boolean]
    def valid?
      @mim.valid?
    end

    def low_contrast?
      @mim.low_contrast?
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
    # @return [Integer]
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
      @mim.barcode_bits.map do |b|
        b ? '1' : '0'
      end.join.reverse
    end

    # Setting the choices/questions to analyze. If this function is not called,
    # the maximum number of choices/questions allowed by the layout will be
    # evaluated.
    #
    # @param choices [Integer, Array] the questions/choices we want subsequent
    #   scoring/overlaying to apply to. Normally, `choices` should be an array
    #   of integers, with each element indicating the number of available
    #   choices for the corresponding question (i.e. `choices.length` is the
    #   number of questions). As a shortcut, `choices` can also be a single
    #   integer value, indicating the number of questions; in such case, the
    #   maximum number of choices allowed by the layout will be considered.
    #
    # @return [Boolean] True if the sheet is properly registered and ready to
    #   be marked; false otherwise.
    def set_choices(choices)
      return false unless valid?
      @mim.set_ch case choices
                  when Integer; @mim.choxq[0...choices]
                  when Array; choices
                  else fail ArgumentError, 'Invalid choice set'
                  end
      true
    end

    # True if the specified question/choice cell has been marked
    #
    # @param question [Integer] the question number, zero-based
    # @param choice [Integer] the choice number, zero-based
    # @return [Boolean]
    def marked?(question, choice)
      return if not_registered
      marked_choices[question].find {|x| x==choice} ? true : false
    end

    # The set of choice indices marked on the response sheet
    #
    # @return [Array] an array of arrays of integers; each element contains
    #   the (zero-based) list of marked choices for the corresponding question.
    #   For example, the following `marked_choices` array: `[[0], [], [3,4]]`
    #   indicates that the responder has marked the first choice for the first
    #   question, none for the second, and the fourth and fifth choices for the
    #   third question.
    def marked_choices
      return if not_registered
      @mim.marked
    end

    # The set of choice indices marked on the response sheet. If more than one
    # choice was marked for a question, the response is regarded as invalid and
    # treated as if it had been left blank.
    #
    # @return [Array] an array of integers; each element contains
    #   the (zero-based) marked choice for the corresponding question.
    def marked_choices_unique
      return if not_registered
      marked_choices.map do |c|
        c.length == 1 ? c.first : nil
      end
    end

    # The set of letters marked on the response sheet. At this time, only the
    # latin sequence 'A, B, C...' is supported.
    #
    # @return [Array] an array of arrays of 1-character strings; each element
    #   contains the list of letters marked for the corresponding question.
    def marked_letters
      return if not_registered
      marked_choices.map do |q|
        q.map { |cho| (65+cho).chr }
      end
    end

    # The set of letters marked on the response sheet. At this time, only the
    # latin sequence 'A, B, C...' is supported. If more than one choice was
    # marked for an item, the response is regarded as invalid and treated as if
    # it had been left blank.
    #
    # @return [Array] an array of 1-character strings
    def marked_letters_unique
      return if not_registered
      marked_choices_unique.map do |c|
        c.nil?? '' : (65+c).chr
      end
    end

    # Apply an overlay on the image
    #
    # @param what [Symbol] the overlay type, choose from `:outline`, `:check`,
    #   `:highlight`
    # @param where [Array, Symbol] where to apply the overlay. Either an array
    #   of arrays of (zero-based) indices to specify target cells, or one of
    #   the following symbols: `:marked`: all marked cells, among those
    #   specified by the `choices` argument during object creation
    #   (this is the default); `:all`: all cells in `choices`;
    #   `:max`: maximum number of cells allowed by the layout (can be larger
    #   than `:all`); `:barcode`: the dark barcode elements; `:cal` the
    #   calibration cells
    def overlay(what, where=:marked)
      return if not_registered
      @mim.overlay what, where
    end

    # Saves a copy of the source image after registration;
    # the output image will also contain any previously applied overlays.
    #
    # @param fname [String] the path/filename of the target image, including
    #   the extension (`.jpg`, `.png`)
    def save(fname)
      return if not_registered
      @mim.save(fname, true)
    end

    # Saves a copy of the original image with overlays showing the crop areas
    # used to localize the registration marks and the detected registration
    # mark centers.
    #
    # @param fname [String] the path/filename of the target image, including
    #   the extension (`.jpg`, `.png`)
    def save_registration(fname)
      @mim.save_registration fname
    end

    # ============================================================#
    private                                                       #
    # ============================================================#

    def not_registered
      unless valid?
        puts "---=={ Unregistered image. Reason: '#{@mim.status.inspect}' }==---"
        true
      end
    end
  end
end
