require 'mini_magick'

module Mork
  # Magicko: image management, done in two ways: 1) direct system calls to
  # imagemagick tools; 2) via the MiniMagick gem
  class Magicko
    def initialize(path)
      @path = path
      @cmd = []
    end

    def width
      img_size[0]
    end

    def height
      img_size[1]
    end

    # registered_bytes returns an array of the same size as the original image,
    # but with pixels stretched out based on the passed perspective points
    # (i.e. the centers of the four registration marks)
    # pp: a hash in the form of pp[:tl][:x], pp[:tl][:y], etc.
    def registered_bytes(pp)
      read_bytes "-distort Perspective '#{pps pp}'"
    end

    # def rm_patch(coord, blur_factor, dilate_factor)
    def rm_patch(c, blr=0, dlt=0)
      b = blr==0 ? '' : " -blur #{blr*3}x#{blr}"
      d = dlt==0 ? '' : " -morphology Dilate Octagon:#{dlt}"
      read_bytes "-crop #{c.cropper}#{b}#{d}"
    end

    # MiniMagick stuff

    def highlight_cells(coords)
      @cmd << [:stroke, 'none']
      @cmd << [:fill, 'rgba(255, 255, 0, 0.3)']
      coords.each do |c|
        @cmd << [:draw, "roundrectangle #{c.choice_cell}"]
      end
    end

    def outline(coords)
      @cmd << [:stroke, 'green']
      @cmd << [:strokewidth, '2']
      @cmd << [:fill, 'none']
      coords.each do |c|
        @cmd << [:draw, "roundrectangle #{c.choice_cell}"]
      end
    end

    def cross(coords)
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

    def write(fname, reg)
      if fname
        MiniMagick::Tool::Convert.new(whiny: false) do |img|
          img << @path
          exec_mm_cmd img, reg
          img << fname
        end
      else
        MiniMagick::Tool::Mogrify.new(whiny: false) do |img|
          img << @path
          exec_mm_cmd img, reg
        end
      end
    end

    private

    # calling imagemagick and capturing the converted image
    # into an array of bytes
    def read_bytes(params=nil)
      s = "|convert #{@path} #{params} gray:-"
      IO.read(s).unpack 'C*'
    end

    def exec_mm_cmd(c, pp)
      c.distort(:perspective, pps(pp)) if pp
      @cmd.each { |cmd| c.send(*cmd) }
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

    def img_size
      @img_size ||= begin
        s = "|identify -format '%w,%h' #{@path}"
        IO.read(s).split(',').map(&:to_i)
      end
    end
  end
end

# def patch(shape: nil, wid: width, hei: height)
#   s = "|convert #{@path} #{shape} gray:-"
#   bytes = IO.read(s).unpack 'C*'
#   NPatch.new bytes, wid, hei
# end

# # raw_patch returns an array containing the pixels of the original image
# def raw_patch
#   @raw_pixels ||= patch
# end
