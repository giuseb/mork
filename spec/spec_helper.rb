require 'mork'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

class SampleImager
  attr_reader :info, :reg_marks, :q_boxes, :barcode_string, :barcode_int
  
  def initialize(which)
    ya = YAML.load_file("./spec/samples/info.yml")
    @info        = ya[which.to_s]
    @reg_marks   = @info["reg_marks"]
    @q_boxes     = @info["q_boxes"]
    @barcode_string = @info["barcode_string"]
    @barcode_int    = @info["barcode_int"]
  end
  
  def filename
    @info["filename"]
  end
  
  def width
    @info["width"]
  end
  
  def height
    @info["height"]
  end
  
  def pages
    @info["pages"]
  end
end

def sample_img(which)
  SampleImager.new(which)
end
