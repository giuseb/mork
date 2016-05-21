require 'mini_magick'
require 'mork/npatch'

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

    # raw_patch returns an NPatch containing the pixels of the original image
    def raw_patch
      @raw_pixels ||= patch
    end

    # reg_patch returns an NPatch of the same size as the original image, but
    # with pixels stretched out based on the passed perspective points (i.e.
    # the centers of the four registration marks)
    # pp: a hash in the form of pp[:tl][:x], pp[:tl][:y], etc.
    def reg_patch(pp)
      @reg_pixels ||= patch(shape: "-distort Perspective '#{pps pp}'")
    end

    def rm_patch(corner, side)
      sh = "-gravity #{gravity corner} -crop #{side}x#{side}+0+0"
      patch shape: sh, wid: side, hei: side
    end

    # MiniMagick stuff

    def highlight_cells(cellcoord, roundedness)
      @cmd << [:stroke, 'none']
      @cmd << [:fill, 'rgba(255, 255, 0, 0.3)']
      cellcoord.each do |c|
        roundedness ||= [c[:h], c[:w]].min / 2
        pts = [c[:x], c[:y], c[:x]+c[:w], c[:y]+c[:h], roundedness, roundedness].join ' '
        @cmd << [:draw, "roundrectangle #{pts}"]
      end
    end

    def outline(cellcoord, roundedness)
      @cmd << [:stroke, 'green']
      @cmd << [:strokewidth, '2']
      @cmd << [:fill, 'none']
      cellcoord.each do |c|
        roundedness ||= [c[:h], c[:w]].min / 2
        pts = [c[:x], c[:y], c[:x]+c[:w], c[:y]+c[:h], roundedness, roundedness].join ' '
        @cmd << [:draw, "roundrectangle #{pts}"]
      end
    end

    def cross(cellcoord, corner)
      @cmd << [:stroke, 'red']
      @cmd << [:strokewidth, '3']
      cellcoord.each do |c|
        pts = [
          c[:x]+corner,
          c[:y]+corner,
          c[:x]+c[:w]-corner,
          c[:y]+c[:h]-corner
        ].join ' '
        @cmd << [:draw, "line #{pts}"]
        pts = [
          c[:x]+corner,
          c[:y]+c[:h]-corner,
          c[:x]+c[:w]-corner,
          c[:y]+corner
        ].join ' '
        @cmd << [:draw, "line #{pts}"]
      end
    end

    def highlight_rect(areas)
      return if areas.empty?
      @cmd << [:fill, 'none']
      @cmd << [:stroke, 'yellow']
      @cmd << [:strokewidth, 3]
      areas.each do |c|
        pts = [c[:x], c[:y], c[:x]+c[:w], c[:y]+c[:h]].join ' '
        @cmd << [:draw, "rectangle #{pts}"]
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
        MiniMagick::Tool::Convert.new(false) do |img|
          img << @path
          exec_mm_cmd img, reg
          img << fname
        end
      else
        MiniMagick::Tool::Mogrify.new(false) do |img|
          img << @path
          exec_mm_cmd img, reg
        end
      end
    end

    private

    def exec_mm_cmd(c, pp)
      c.distort(:perspective, pp) if pp
      @cmd.each { |cmd| c.send(*cmd) }
    end

    def patch(shape: nil, wid: width, hei: height)
      s = "|convert #{@path} #{shape} gray:-"
      bytes = IO.read(s).unpack 'C*'
      NPatch.new bytes, wid, hei
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

    def gravity(corner)
      case corner
      when :tl
        :NorthWest
      when :tr
        :NorthEast
      when :br
        :SouthEast
      when :bl
        :SouthWest
      end
    end
  end
end
