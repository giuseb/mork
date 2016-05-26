require 'mork'

RSpec.configure do |config|
  config.filter_run focus: true
  config.filter_run_excluding exclude: true
  config.run_all_when_everything_filtered = true
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

RSpec::Matchers.define :have_coords do |x, y, w, h|
  match do |coord|
    coord.x == x and coord.y == y and coord.w == w and coord.h == h
  end
end

class SampleImager
  attr_reader :info

  def initialize(which)
    ya = YAML.load_file("./spec/samples/info.yml")
    @info = ya[which.to_s]
  end

  def grid_file
    @info["grid-file"]
  end

  def reg_marks
    @info["reg-marks"]
  end

  def q_boxes
    @info["q-boxes"]
  end

  def barcode_string
    @info["barcode-string"]
  end

  def barcode_int
    @info["barcode-int"]
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

def lorem
  "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
end
