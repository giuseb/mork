# @private
class Fixnum
  def mm
    self * 2.83464566929134
  end
end

# @private
class Float
  def mm
    self * 2.83464566929134
  end
end

module Mork
  # @private
  module Extensions
    def symbolize(obj)
      return obj.inject({}){|memo,(k,v)| memo[k.to_sym] =  symbolize(v); memo} if obj.is_a? Hash
      return obj.inject([]){|memo,v    | memo           << symbolize(v); memo} if obj.is_a? Array
      return obj
    end
  end
end

# # @private
# class Array
#   def mean
#     @the_sample_mean ||= inject(:+)/length.to_f
#   end
#   def sample_variance
#     sum = inject(0){|accum, i| accum + (i-mean)**2 }
#     sum/(length - 1).to_f
#   end
#   def stdev
#     Math.sqrt sample_variance
#   end
# end

