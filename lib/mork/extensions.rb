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

class Fixnum
  def mm
    self * 2.83464566929134
  end
end

class Float
  def mm
    self * 2.83464566929134
  end
end
