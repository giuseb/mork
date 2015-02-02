require 'yaml'
require 'mork/grid_const'

module Mork
  # The Grid is a set of expectations on what the response sheet should look like
  # It knows nothing about the actual scanned image.
  # All returned values are in the arbitrary units given in the configuration file
  class Grid
    # Calling Grid.new without arguments creates the default boilerplate Grid
    def initialize(options=nil)
      @params = DGRID
      case options
      when NilClass
        if File.exists?('layout.yml')
          @params.merge! symbolize YAML.load_file('layout.yml')
        end
      when Hash
        @params.merge! symbolize options
      when String
        @params.merge! symbolize YAML.load_file(options)
      else
        raise "Invalid parameter in the Grid constructor: #{options.class.inspect}"
      end
    end
    
    # Puts out the Grid parameters in YAML format; the entire hash is displayed
    # if no arguments are given; you can specify what to show by passing one of:
    # :page_size, :reg_marks, :header, :items, :barcode, :control
    def show(subset=nil)
      out = subset ? @params[subset] : @params
      puts out.to_yaml
    end
    
    def options
      @params
    end
    
    def max_questions
      columns * rows
    end
    
    def max_choices_per_question
      @params[:items][:max_cells].to_i
    end
    
    def barcode_bits
      @params[:barcode][:bits].to_i
    end
    
    #====================#
    private
    #====================#
    
    # recursively turn hash keys into symbols. pasted from
    # http://stackoverflow.com/questions/800122/best-way-to-convert-strings-to-symbols-in-hash
    def symbolize(obj)
      return obj.inject({}){|memo,(k,v)| memo[k.to_sym] =  symbolize(v); memo} if obj.is_a? Hash
      return obj.inject([]){|memo,v    | memo           << symbolize(v); memo} if obj.is_a? Array
      return obj
    end
  
    # cell_y(q)
    # 
    # the distance from the registration frame to the top edge
    # of all choice cells in the q-th question
    def cell_y(q)
      first_y + item_spacing * (q % rows) - cell_height / 2
    end
    
    # cell_x(q,c)
    # 
    # the distance from the registration frame to the left edge
    # of the c-th choice cell of the q-th question
    def cell_x(q,c)
      item_x(q) + cell_spacing * c
    end
    
    def item_x(q)
      first_x + column_width * (q / rows) - cell_width / 2
    end
    
    def cal_cell_x
      reg_frame_width - cell_spacing
    end
    
    # ===========
    # = barcode =
    # ===========
    def barcode_bit_x(i)
      @params[:barcode][:left] + @params[:barcode][:spacing] * i
    end
    
    # ===============================
    # = Simple parameter extraction =
    # ===============================
    def barcode_y()         reg_frame_height - barcode_height   end
    def barcode_height()    @params[:barcode][:height].to_f     end
    def barcode_width()     @params[:barcode][:width].to_f      end
    def cell_width()        @params[:items][:cell_width].to_f   end
    def cell_height()       @params[:items][:cell_height].to_f  end
    def cell_spacing()      @params[:items][:x_spacing].to_f    end
    def item_spacing()      @params[:items][:y_spacing].to_f    end
    def column_width()      @params[:items][:column_width].to_f end
    def first_x()           @params[:items][:left].to_f         end
    def first_y()           @params[:items][:top].to_f          end
    def rows()              @params[:items][:rows]              end
    def columns()           @params[:items][:columns]           end
    def reg_search()        @params[:reg_marks][:search].to_f    end
    def reg_off()           @params[:reg_marks][:offset].to_f    end
    def reg_frame_width()   page_width  - reg_margin * 2        end
    def reg_frame_height()  page_height - reg_margin * 2        end
    def page_width()        @params[:page_size][:width].to_f    end
    def page_height()       @params[:page_size][:height].to_f   end
    def reg_margin()        @params[:reg_marks][:margin].to_f    end
    def reg_radius()        @params[:reg_marks][:radius].to_f    end
  end
end
