# encoding: UTF-8
require "bb_openstruct/version"

class BBOpenStruct
  class << self # :nodoc:
    alias allocate new
  end

  def initialize(hash={})
    @binding = BBOpenStruct.pure_binding
    hash.each_pair do |k,v|
      @binding.local_variable_set(k.to_sym, v)
    end
    @binding.local_variables.each do |name|
      get = ->() { @binding.local_variable_get(name) }
      set = ->(new_var) { @binding.local_variable_set(name, new_var) }
      define_singleton_method(name, get)
      define_singleton_method("#{name}=".to_sym, set)
    end
  end

  def self.pure_binding
    binding
  end

  def delete_field(name)
    name = name.to_sym
    binding_old = @binding.dup
    @binding = BBOpenStruct.pure_binding
    binding_old.local_variables.each do |var|
      next if var == name
      @binding.local_variable_set(var, binding_old.local_variable_get(var))
    end

    instance_eval("undef #{name}=")
    instance_eval("undef #{name}")

    binding_old.local_variable_get(name)
  end

  def freeze
    singleton_methods.each do |method|
      instance_eval("undef #{method}") if method.to_s[-1] == '='
    end
    eval("def self.frozen?; true end")
    super
  end

  def method_missing(name, arg=nil)
    name = name.to_sym
    if @binding.local_variables.include?(name)
      @binding.local_variable_get(name)
    elsif name.to_s[-1] == '=' && frozen?
      raise RuntimeError.new "can't modify frozen object"
    elsif name.to_s[-1] == '='
      pure_name = name.to_s.delete('=').to_sym
      @binding.local_variable_set(pure_name, arg)
      unless methods.include?(pure_name)
        set = ->(new_var) { @binding.local_variable_set(pure_name, new_var) }
        get = ->() { @binding.local_variable_get(pure_name) }
        define_singleton_method(name, set)
        define_singleton_method(pure_name, get)
      end
    else
      err = NoMethodError.new "undefined method `#{name}' for #{self}", name, [arg]
      err.set_backtrace caller(1)
      raise err
    end
  end

  def [](name)
    method_missing(name)
  end

  def []=(name, val)
    method_missing("#{name.to_sym}=", val)
  end

  def respond_to_missing?(method_name, include_private = false)
    last_char_name = method_name.to_s[-1]
    if last_char_name == '=' && frozen?
      false
    elsif last_char_name == '=' && @binding.local_variable_defined?(method_name.to_s.tr('=', ''))
      true
    else
      (@binding.local_variables.include?(method_name) && !@binding.local_variable_get(method_name)) || super
    end
  end

  InspectKey = :__inspect_key__ # :nodoc:
  def inspect
    str = "#<#{self.class}"

    ids = (Thread.current[InspectKey] ||= [])
    if ids.include?(object_id)
      return str << ' ...>'
    end

    ids << object_id
    begin
      first = true
      @binding.local_variables.sort.each do |k|
        v = @binding.local_variable_get(k)
        str << "," unless first
        first = false
        str << " #{k}=#{v.inspect}"
      end
      return str << '>'
    ensure
      ids.pop
    end
  end
  alias :to_s :inspect

  def each_pair
    table = {}
    @binding.local_variables.each do |k|
      table[k] = @binding.local_variable_get(k)
    end
    return to_enum(__method__) { table.size } unless block_given?
    table.each_pair{|p| yield p}
  end

  def to_h
    output = {}
    @binding.local_variables.each do |var|
      next if var == :hash
      output[var] = @binding.local_variable_get(var)
    end
    output
  end

  def ==(other)
    return false unless other.kind_of?(BBOpenStruct)
    to_h == other.to_h
  end

  def eql?(other)
    return false unless other.kind_of?(BBOpenStruct)
    to_h.eql?(other.to_h)
  end

  # Compute a hash-code for this OpenStruct.
  # Two hashes with the same content will have the same hash code
  # (and will be eql?).
  def hash
    to_h.hash
  end

  # Retrieves the value object corresponding to the each +name+
  # objects repeatedly.
  #
  #   address = BBOpenStruct.new('city' => "Anytown NC", 'zip' => 12345)
  #   person = BBOpenStruct.new('name' => 'John Smith', 'address' => address)
  #   person.dig(:address, 'zip') # => 12345
  #   person.dig(:business_address, 'zip') # => nil
  #
  def dig(name, *names)
    begin
      name = name.to_sym
    rescue NoMethodError
      raise TypeError, "#{name} is not a symbol nor a string"
    end
    to_h.dig(name, *names)
  end
end
