require 'mork'
require 'byebug'

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

  def method_missing(name)
    @info[name.to_s] || raise("non existing sample key: #{name}")
  end
end

###################
# UTILITY FUNCTIONS
###################

# this is how I manually score a sample sheet, usually;
# see images in /spec/samples/jdoe
def standard_mark_array(n)
  standard_array n, [[0],[1],[2],[3],[4]]
end

def standard_mark_logical_array(n)
  standard_array n, [
        [true, false, false, false, false],
        [false, true, false, false, false],
        [false, false, true, false, false],
        [false, false, false, true, false],
        [false, false, false, false, true],
      ]
end

def standard_mark_char_array(n)
  standard_array n, [['A'],['B'],['C'],['D'],['E']]
end

def standard_array(n, what)
  [].tap do |a|
    n.times do
      a.concat what
    end
  end
end

def sample_img(which)
  SampleImager.new(which)
end

def lorem
  "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
end
