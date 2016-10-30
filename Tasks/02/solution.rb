class Array
  def fetch_deep(keys)
    return self[keys.first.to_i] if keys.size == 1
    self[keys.first.to_i].fetch_deep(keys[1..keys.size])
  end

  def reshape(shape)
    map { |element| element.reshape(shape) }
  end
end

class Hash
  def fetch_deep(keys)
    keys = keys.split('.') if keys.is_a? String
    key = keys.first.to_sym if self.keys.include? keys.first.to_sym
    key = keys.first if self.keys.include? keys.first
    return nil unless key
    return self[key] if keys.size == 1
    self[key].fetch_deep(keys[1..keys.size])
  end

  def reshape(shape)
    reshaped = {}
    shape.each do |key, value|
      if value.is_a? String then reshaped[key] = self.fetch_deep(value) end
      if value.is_a? Hash then reshaped[key] = self.reshape(value) end
    end
    reshaped
  end
end
