require 'mini_magick'
require 'open3'

module Mork
  # @private
  # Magicko: low-level image management, done in two ways: 1) direct system calls to
  # imagemagick tools; 2) via the MiniMagick gem
  class Magicko
    attr_reader :width
    attr_reader :height

    def initialize(path)
      @path = path
      @cmd = []
      # a density is required for processing PDF or other vector-based images;
      # a default of 150 dpi seems sensible. It should not affect bitmaps.
      density = 150
      # inspect the source file
      s1, s2, s3 = Open3.capture3 "identify -density #{density} -format '%w %h %m' #{path}"
      if s3.success?
        # parse the identify command output
        w, h, @type = s1.split(' ')
        @width  = w.to_i
        @height = h.to_i
        if @type.downcase == 'pdf'
          # remember density for later use
          @density = density
        end
      else
        # Inspect the stderr and raise appropriate errors
        case s2
        when /No such file/
          fail Errno::ENOENT
        when /The file has been damaged/
          fail IOError, 'Invalid image. File may have been damaged'
        else
          fail IOError, 'Unknown problem with image file'
        end
      end
    end

    def valid?
      @valid
    end

    # registered_bytes returns an array of the same size as the original image,
    # but with pixels stretched out based on the passed perspective points
    # (i.e. the centers of the four registration marks)
    # pp: a hash in the form of pp[:tl][:x], pp[:tl][:y], etc.
    def registered_bytes(pp)
      read_bytes "-distort Perspective '#{pps pp}'"
    end

    # Reading from the image file the bytes from one of the four corner
    # squares encompassing each registration mark; the blur and dilation
    # manipulations may prevent registration misalignments due to stray dark pixels
    def rm_patch(c, blr=0, dlt=0)
      b = blr==0 ? '' : " -blur #{blr*3}x#{blr}"
      d = dlt==0 ? '' : " -morphology Dilate Octagon:#{dlt}"
      read_bytes "-crop #{c.cropper}#{b}#{d}"
    end

    ##################################
    # Constructing MiniMagick commands
    ##################################

    def highlight(coords, rounded)
      @cmd << [:stroke, 'none']
      @cmd << [:fill, 'rgba(255, 255, 0, 0.3)']
      coords.each { |c| @cmd << [:draw, shape(c, rounded)] }
    end

    def outline(coords, rounded)
      @cmd << [:stroke, 'green']
      @cmd << [:strokewidth, '3']
      @cmd << [:fill, 'none']
      coords.each { |c| @cmd << [:draw, shape(c, rounded)] }
    end

    def check(coords, rounded)
      @cmd << [:stroke, 'red']
      @cmd << [:strokewidth, '3']
      coords.each do |c|
        @cmd << [:draw, "line #{c.cross1}"]
        @cmd << [:draw, "line #{c.cross2}"]
      end
    end

    def plus(x, y, l)
      @cmd << [:stroke, 'red']
      @cmd << [:strokewidth, 1]
      pts = [ x-l, y, x+l, y ].join ' '
      @cmd << [:draw, "line #{pts}"]
      pts = [ x, y-l, x, y+l ].join ' '
      @cmd << [:draw, "line #{pts}"]
    end

    def highlight_area(c)
      @cmd << [:fill, 'none']
      @cmd << [:stroke, 'yellow']
      @cmd << [:strokewidth, 3]
      @cmd << [:draw, "rectangle #{c.rect_points}"]
    end

    def highlight_rect(areas)
      return if areas.empty?
      @cmd << [:fill, 'none']
      @cmd << [:stroke, 'yellow']
      @cmd << [:strokewidth, 3]
      areas.each do |c|
        @cmd << [:draw, "rectangle #{c.rect_points}"]
      end
    end

    def join(p)
      @cmd << [:fill, 'none']
      @cmd << [:stroke, 'green']
      @cmd << [:strokewidth, 3]
      pts = [
        p[0][:x], p[0][:y],
        p[1][:x], p[1][:y],
        p[2][:x], p[2][:y],
        p[3][:x], p[3][:y]
      ].join ' '
      @cmd << [:draw, "polygon #{pts}"]
    end

    def save(fname, reg)
      MiniMagick::Tool::Convert.new(whiny: false) do |img|
        img << '-density' << @density if @density
        img << @path
        img.distort(:perspective, pps(reg)) if reg
        @cmd.each { |cmd| img.send(*cmd) }
        img << fname
      end
    end

    private

    def shape(c, rounded)
      rounded ? "roundrectangle #{c.choice_cell}" : "rectangle #{c.rect_points}"
    end

    # calling imagemagick and capturing the converted image
    # into an array of bytes
    def read_bytes(params=nil)
      d = @density ? "-density #{@density}" : nil
      s = "|convert -depth 8 #{d} #{@path} #{params} gray:-"
      IO.read(s).unpack 'C*'
    end

    # perspective points: brings the found registration area centers to the
    # original image boundaries; the result is that the registered image is
    # somewhat stretched, which should be okay
    def pps(pp)
      [
        pp[:tl][:x], pp[:tl][:y],     0,      0,
        pp[:tr][:x], pp[:tr][:y], width,      0,
        pp[:br][:x], pp[:br][:y], width, height,
        pp[:bl][:x], pp[:bl][:y],     0, height
      ].join ' '
    end
  end
end

# @pdf = File.extname(path).strip.downcase[1..-1] == 'pdf'
# @pdf_den = 150 # dpi
# get_info_and_test_sanity

# def width
#   img_size[0]
# end

# def height
#   img_size[1]
# end
# if s1.downcase=='pdf'
#   @density = 150
#   @den_str = "-density #{@density}"
# end

# def img_size
#   @img_size ||= begin
#     s = "|identify -format '%w,%h' #{@density} #{@path}"
#     IO.read(s).split(',').map(&:to_i)
#   end
# end

# def parse_from_stdout(s1)
#   w, h, t = s1.split ','
#   return w.to_i, h.to_i, t
# end
