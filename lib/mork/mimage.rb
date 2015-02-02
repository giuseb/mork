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
      @rm   = {} # registration mark centers
      @rmsa = {} # registration mark search area
      @valid = register
      @writing = nil
      @cmd = []
    end
    
    def valid?
      @valid
    end
    
    def status
      {
        tl: @rm[:tl][:status],
        tr: @rm[:tr][:status],
        br: @rm[:br][:status],
        bl: @rm[:bl][:status],
        write: @writing
      }
    end
    
    def ink_black
      reg_pixels.average @grom.ink_black_area
    end
    
    def paper_white
      reg_pixels.average @grom.paper_white_area
    end
    
    def cal_cell_mean
      @grom.calibration_cell_areas.collect { |c| reg_pixels.average c }.mean
    end
    
    def shade_of_barcode_bit(i)
      reg_pixels.average @grom.barcode_bit_area i+1
    end
    
    def shade_of(q,c)
      reg_pixels.average @grom.choice_cell_area(q, c)
    end
    
    def width
      img_size[0].to_i
    end
    
    def height
      img_size[1].to_i
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
      coordinates_of(cells).each do |c|
        roundedness ||= [c[:h], c[:w]].min / 2
        pts = [c[:x], c[:y], c[:x]+c[:w], c[:y]+c[:h], roundedness, roundedness].join ' '
        @cmd << [:draw, "roundrectangle #{pts}"]
      end
    end
    
    def highlight_all_choices
      cells = (0...@grom.max_questions).collect { |i| (0...@grom.max_choices_per_question).to_a }
      highlight_cells cells
    end
    
    # highlight_cells(cells, roundedness)
    # 
    # partially transparent yellow on top of choice cells
    def highlight_cells(cells, roundedness=nil)
      return if cells.empty?
      @cmd << [:stroke, 'none']
      @cmd << [:fill, 'rgba(255, 255, 0, 0.3)']
      coordinates_of(cells).each do |c|
        roundedness ||= [c[:h], c[:w]].min / 2
        pts = [c[:x], c[:y], c[:x]+c[:w], c[:y]+c[:h], roundedness, roundedness].join ' '
        @cmd << [:draw, "roundrectangle #{pts}"]
      end
    end
    
    def highlight_reg_area
      highlight_rect [@rmsa[:tl], @rmsa[:tr], @rmsa[:br], @rmsa[:bl]]
      return unless valid?
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
    
    def cross(cells)
      return if cells.empty?
      cells = [cells] if cells.is_a? Hash
      @cmd << [:stroke, 'red']
      @cmd << [:strokewidth, '3']
      coordinates_of(cells).each do |c|
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
    
    # write the underlying MiniMagick::Image to disk;
    # if no file name is given, image is processed in-place;
    # if the 2nd arg is false, then stretching is not applied
    def write(fname=nil, reg=true)
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
    
    # ============================================================#
    private                                                       #
    # ============================================================#
    def exec_mm_cmd(c, reg)
      c.distort(:perspective, perspective_points) if reg
      @cmd.each { |cmd| c.send *cmd }
    end
    
    def img_size
      @img_size ||= IO.read("|identify -format '%w,%h' #{@path}").split ','
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
    
    def perspective_points
      [
        @rm[:tl][:x], @rm[:tl][:y],     0,      0,
        @rm[:tr][:x], @rm[:tr][:y], width,      0,
        @rm[:br][:x], @rm[:br][:y], width, height,
        @rm[:bl][:x], @rm[:bl][:y],     0, height
      ].join ' '
    end

    def join(p)
      @cmd << [:fill, 'none']
      @cmd << [:stroke, 'green']
      @cmd << [:strokewidth, 3]
      pts = [p[0][:x], p[0][:y], p[1][:x], p[1][:y], p[2][:x], p[2][:y], p[3][:x], p[3][:y]].join ' '
      @cmd << [:draw, "polygon #{pts}"]
    end
        
    def coordinates_of(cells)
      cells.collect.each_with_index do |q, i|
        q.collect { |c| @grom.choice_cell_area(i, c) }
      end.flatten
    end
    
    def corner
      @corner_size ||= @grom.cell_corner_size
    end

    def register
      # find the XY coordinates of the 4 registration marks
      @rm[:tl] = reg_centroid_on(:tl)
      # puts "TL: #{@rm[:tl][:status].inspect}"
      @rm[:tr] = reg_centroid_on(:tr)
      # puts "TR: #{@rm[:tr][:status].inspect}"
      @rm[:br] = reg_centroid_on(:br)
      # puts "BR: #{@rm[:br][:status].inspect}"
      @rm[:bl] = reg_centroid_on(:bl)
      # puts "BL: #{@rm[:bl][:status].inspect}"
      @rm.all? { |k,v| v[:status] == :ok }      
    end
    
    # returns the centroid of the dark region within the given area
    # in the XY coordinates of the entire image
    def reg_centroid_on(corner)
      1000.times do |i|
        @rmsa[corner] = @grom.rm_search_area(corner, i)
        # puts "================================================================"
        # puts "Corner #{corner} - Iteration #{i} - Coo #{@rmsa[corner].inspect}"
        cx, cy = raw_pixels.dark_centroid @rmsa[corner]
        if cx.nil?
          status = :no_contrast  
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
  end
end
