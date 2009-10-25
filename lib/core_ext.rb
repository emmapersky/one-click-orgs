class Symbol
  def to_proc
    proc { |obj, *args|
      obj.send(self, *args)
    }
  end
end

class Array
  # Stolen from Rails
  def to_sentence
    case length
      when 0
        ""
      when 1
        self[0].to_s
      when 2
        "#{self[0]} and #{self[1]}"
      else
        "#{self[0...-1].join(', ')} and #{self[-1]}"
    end
  end
end
