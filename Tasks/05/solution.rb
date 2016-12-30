class DataModel
  attr_accessor :store

  class DeleteUnsavedRecordError < StandardError
  end

  def initialize(attributes = {})
    @store = self.class.data_store
    @attributes = attributes.select { |key, _| self.class.attributes.include? key }
  end

  def save
    if store.find(@attributes).empty?
      store.create(@attributes)
    else
      store.update id: @attributes[:id], attributes: @attributes
    end
  end

  # => focus here
  def delete
    if store.find(@attributes).empty?
      raise DeleteUnsavedRecordError
    else
      store.delete(@attributes[:id])
    end
  end

  def self.inspect_store
    p data_store
  end

  class << self
    def data_store(store=nil)
      return @data_store unless store
      @data_store = store
    end

    def attributes(*attrs)
      return @attributes if attrs.empty?
      @attributes = attrs + [:id]

      @attributes.each do |attribute|
        define_method "#{attribute}=" do |arg|
          @attributes[attribute] = arg
        end

        define_method attribute do
          @attributes[attribute]
        end

        define_singleton_method "find_by_#{attribute}" do |value|
          where(attribute => value)
        end
      end
    end

    def where(query)
      data_store.find(query).map{|el| new el}
    end
  end
end

class ArrayStore
  attr_reader :id, :storage

  def initialize
    @id = 0
    @storage = []
  end

  def create
  end

  def find
  end

  def update
  end

  def delete
  end
end

class HashStore
  attr_reader :id, :storage

  def initialize
    @id = 0
    @storage = {}
  end

  def create(attributes)
    @id += 1
    attributes[:id] = @id
    storage[@id] = attributes
  end

  def find(query)
    storage.values.select do |value|
      query.all? {|key,val| value[key]==val}
    end
  end

  def update(id:, attributes:)
    storage[id] = attributes
  end

  def delete(query)
    storage.delete(query)
  end
end
