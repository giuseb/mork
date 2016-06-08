# @private
class Array
  def mean
    @the_sample_mean ||= inject(:+)/length.to_f
  end

  def sample_variance
    sum = inject(0){|accum, i| accum + (i-mean)**2 }
    sum/(length - 1).to_f
  end

  def stdev
    Math.sqrt sample_variance
  end
end

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

# @private
class Hash
  def morks_deep_merge(second)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    self.merge(second, &merger)
  end
end
