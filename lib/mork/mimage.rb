require 'mini_magick'
require 'mork/npatch'

module Mork
  # The class Mimage is a wrapper for the core image library, currently mini_magick
  class Mimage
    def initialize(path, grom, page=0)
      raise "File '#{path}' not found" unless File.exists? path
      @path = path
      @grom = grom
      @grom.set_page_size width, height
      @status = register
      @cmd = []
    end
    
    def status
      @status
    end
    
    def ink_black
      reg_pixels.average @grom.ink_black_area
    end
    
    def paper_white
      reg_pixels.average @grom.paper_white_area
    end
    
    def cal_cell_means
      @grom.calibration_cell_areas.collect { |c| reg_pixels.average c }
    end
    
    def shade_of_barcode_bit(i)
      reg_pixels.average @grom.barcode_bit_area i+1
    end
    
    def shade_of(q,c)
      reg_pixels.average @grom.choice_cell_area(q, c)
    end
    
    def path
      @path
    end
    
    def width
      @width  ||= IO.read("|identify -format '%w' #{@path}").to_i
    end
    
    def height
      @height ||= IO.read("|identify -format '%h' #{@path}").to_i
    end
    
    def raw_pixels
      @raw_pixels ||= begin
        bytes = IO.read("|convert #{@path} gray:-").unpack 'C*'
        NPatch.new bytes, width, height
      end
    end
    
    def reg_pixels
      @reg_pixels ||= begin
        bytes = IO.read("|convert #{@path} -distort Perspective '#{perspective_points}' gray:-").unpack 'C*'
        NPatch.new bytes, width, height
      end
    end
    
    
    # outline(cells, roundedness)
    # 
    # draws on the Mimage a set of cell outlines
    # typically used to highlight the expected responses
    def outline(cells, roundedness=nil)
      return if cells.empty?
      @cmd << [:stroke, 'green']
      @cmd << [:strokewidth, '4']
      @cmd << [:fill, 'none']
      array_of(cells).each do |c|
        roundedness ||= [c[:h], c[:w]].min / 2
        pts = [c[:x], c[:y], c[:x]+c[:w], c[:y]+c[:h], roundedness, roundedness].join ' '
        @cmd << [:draw, "roundrectangle #{pts}"]
      end
    end
    
    def highlight_all_choices
      cells = (0...@grom.max_questions).collect { |i| (0...@grom.max_choices_per_question).to_a }
      highlight_cells cells
      # @crop.highlight_cells! array_of cells
      # @crop.highlight_cells! @grom.calibration_cell_areas
      # @crop.highlight_rect! [@grom.ink_black_area, @grom.paper_white_area]
      # @crop.highlight_rect! @grom.barcode_bit_areas
    end
    
    # highlight_cells(cells, roundedness)
    # 
    # partially transparent yellow on top of choice cells
    def highlight_cells(cells, roundedness=nil)
      return if cells.empty?
      @cmd << [:fill, 'rgba(255, 255, 0, 0.3)']
      array_of(cells).each do |c|
        roundedness ||= [c[:h], c[:w]].min / 2
        pts = [c[:x], c[:y], c[:x]+c[:w], c[:y]+c[:h], roundedness, roundedness].join ' '
        @cmd << [:draw, "roundrectangle #{pts}"]
      end
    end
    
    def highlight_reg_area
      highlight_rect [@rmsa[:tl], @rmsa[:tr], @rmsa[:br], @rmsa[:bl]]
      return unless @status
      join [@rm[:tl], @rm[:tr], @rm[:br], @rm[:bl]]
    end
    
    def highlight_barcode(bitstring)
      highlight_rect @grom.barcode_bit_areas bitstring
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
    
    def cross_cells!(cells)
      cells = [cells] if cells.is_a? Hash
      cells.each do |c|
        out = Magick::Draw.new
        out.stroke 'yellow'
        out.stroke_width 3
        out.line
      end
    end
    
    def join(p)
      @cmd << [:fill, 'none']
      @cmd << [:stroke, 'green']
      @cmd << [:strokewidth, 3]
      pts = [p[0][:x], p[0][:y], p[1][:x], p[1][:y], p[2][:x], p[2][:y], p[3][:x], p[3][:y]].join ' '
      @cmd << [:draw, "polygon #{pts}"]
    end
    
    # ============
    # = Cropping =
    # ============
    def crop(c)
      Mimage.new @image.crop(c[:x], c[:y], c[:w], c[:h])
    end
    
    def crop!(c)
      @image.crop!(c[:x], c[:y], c[:w], c[:h])
      self
    end
    
    # ============
    # = Blurring =
    # ============
    def blur(a, b)
      Mimage.new @image.blur_image(a, b)
    end

    def blur!(a, b)
      @image = @image.blur_image(a, b)
      self
    end
    
    # ==============
    # = Stretching =
    # ==============
    def stretch(points)
      Mimage.new @image.distort(Magick::PerspectiveDistortion, points)
    end
    
    def stretch!(points)
      @image = @image.distort(Magick::PerspectiveDistortion, points)
      self
    end
    
    
    # write the underlying MiniMagick::Image to disk;
    # if the 2nd arg is false, then then stretching is not applied
    def write(fname, reg=true)
      img = MiniMagick::Image.open @path
      img.combine_options do |c|
        c.distort(:perspective, perspective_points) if reg
        @cmd.each do |cmd|
          c.send *cmd
        end
      end
      img.write fname
    end
    
    def write_raw(fname)
      
    end
    
    # =======#
    private  #
    # =======#
    
    def perspective_points
      [
        @rm[:tl][:x], @rm[:tl][:y],     0,      0,
        @rm[:tr][:x], @rm[:tr][:y], width,      0,
        @rm[:br][:x], @rm[:br][:y], width, height,
        @rm[:bl][:x], @rm[:bl][:y],     0, height
      ].join ' '
    end

    def array_of(cells)
      out = []
      cells.each_with_index do |q, i|
        q.each do |c|
          out << @grom.choice_cell_area(i, c)
        end
      end
      out
    end

    
    def register
      # find the XY coordinates of the 4 registration marks
      @rm   = {} # registration mark centers
      @rmsa = {} # registration mark search area
      @rm[:tl] = reg_centroid_on(:tl)
      @rm[:tr] = reg_centroid_on(:tr)
      @rm[:br] = reg_centroid_on(:br)
      @rm[:bl] = reg_centroid_on(:bl)
      # return the status
      @rm.all? { |k,v| v[:status] == :ok }
    end
    
    # returns the centroid of the dark region within the given area
    # in the XY coordinates of the entire image
    def reg_centroid_on(corner)
      1000.times do |i|
        @rmsa[corner] = @grom.rm_search_area(corner, i)
        cx, cy = raw_pixels.dark_centroid @rmsa[corner]
        if cx.nil?
          status = :insufficient_contrast  
        elsif (cx < @grom.rm_edgy_x) or
              (cy < @grom.rm_edgy_y) or
              (cy > @rmsa[corner][:h] - @grom.rm_edgy_y) or
              (cx > @rmsa[corner][:w] - @grom.rm_edgy_x)
          status = :edgy
        else
          return {status: :ok, x: cx + @rmsa[corner][:x], y: cy + @rmsa[corner][:y]}
        end
        return {status: status, x: nil, y: nil} if @rmsa[corner][:w] > @grom.rm_max_search_area_side
      end
    end
    
    def img
      @minimage ||= MiniMagick::Image.open @path
    end
  end
end

# if img.class == String
#   if File.extname(img) == '.pdf'
#     @image = MiniMagick::Image.open(img) { self.density = 200 }[page]
#   else
#     @image = Magick::ImageList.new(img)[page]
#   end
# elsif img.class == Magick::ImageList
#   @image = img[page]
# elsif img.class == Magick::Image
#   @image = img
# else
#   raise "Invalid initialization argument"
# end

# def width
#   @image[:width]
# end
#
# def height
#   @image[:height]
# end
