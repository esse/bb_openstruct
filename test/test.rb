# encoding: UTF-8
# frozen_string_literal: false
require 'test/unit'
require_relative '../lib/bb_openstruct'

# Test comes from original Ruby BBOpenStruct implementation
# https://github.com/ruby/ruby/blob/trunk/test/ostruct/test_ostruct.rb
# to ensure 100% API compatibility

class TC_BBOpenStruct < Test::Unit::TestCase
  def test_initialize
    h = {name: "John Smith", age: 70, pension: 300}
    assert_equal h, BBOpenStruct.new(h).to_h
    assert_equal h, BBOpenStruct.new(BBOpenStruct.new(h)).to_h
    assert_equal h, BBOpenStruct.new(Struct.new(*h.keys).new(*h.values)).to_h
  end

  def test_respond_to
    o = BBOpenStruct.new
    o.a = 1
    assert_respond_to(o, :a)
    assert_respond_to(o, :a=)
  end

  def test_respond_to_with_lazy_getter
    o = BBOpenStruct.new a: 1
    assert_respond_to(o, :a)
    assert_respond_to(o, :a=)
  end

  def test_respond_to_allocated
    assert_not_respond_to(BBOpenStruct.allocate, :a)
  end

  def test_equality
    o1 = BBOpenStruct.new
    o2 = BBOpenStruct.new
    assert_equal(o1, o2)

    o1.a = 'a'
    assert_not_equal(o1, o2)

    o2.a = 'a'
    assert_equal(o1, o2)

    o1.a = 'b'
    assert_not_equal(o1, o2)

    o2 = Object.new
    o2.instance_eval{@table = {:a => 'b'}}
    assert_not_equal(o1, o2)
  end

  def test_inspect
    foo = BBOpenStruct.new
    assert_equal("#<BBOpenStruct>", foo.inspect)
    foo.bar = 1
    foo.baz = 2
    assert_equal("#<BBOpenStruct bar=1, baz=2>", foo.inspect)

    foo = BBOpenStruct.new
    foo.bar = BBOpenStruct.new
    assert_equal('#<BBOpenStruct bar=#<BBOpenStruct>>', foo.inspect)
    foo.bar.foo = foo
    assert_equal('#<BBOpenStruct bar=#<BBOpenStruct foo=#<BBOpenStruct ...>>>', foo.inspect)
  end

  def test_frozen
    o = BBOpenStruct.new(foo: 42)
    o.a = 'a'
    o.freeze
    assert_raise(RuntimeError) {o.b = 'b'}
    assert_not_respond_to(o, :b)
    assert_raise(RuntimeError) {o.a = 'z'}
    assert_equal('a', o.a)
    assert_equal(42, o.foo)
    o = BBOpenStruct.new :a => 42
    def o.frozen?; nil end
    o.freeze
    assert_raise(RuntimeError, '[ruby-core:22559]') {o.a = 1764}
  end

  def test_delete_field
    bug = '[ruby-core:33010]'
    o = BBOpenStruct.new
    assert_not_respond_to(o, :a)
    assert_not_respond_to(o, :a=)
    o.a = 'a'
    assert_respond_to(o, :a)
    assert_respond_to(o, :a=)
    a = o.delete_field :a
    assert_not_respond_to(o, :a, bug)
    assert_not_respond_to(o, :a=, bug)
    assert_equal(a, 'a')
    s = Object.new
    def s.to_sym
      :foo
    end
    o[s] = true
    assert_respond_to(o, :foo)
    assert_respond_to(o, :foo=)
    o.delete_field s
    assert_not_respond_to(o, :foo)
    assert_not_respond_to(o, :foo=)
  end

  def test_setter
    os = BBOpenStruct.new
    os[:foo] = :bar
    assert_equal :bar, os.foo
    os['foo'] = :baz
    assert_equal :baz, os.foo
  end

  def test_getter
    os = BBOpenStruct.new
    os.foo = :bar
    assert_equal :bar, os[:foo]
    assert_equal :bar, os['foo']
  end

  def test_dig
    os1 = BBOpenStruct.new
    os2 = BBOpenStruct.new
    os1.child = os2
    os2.foo = :bar
    os2.child = [42]
    assert_equal :bar, os1.dig("child", :foo)
    assert_nil os1.dig("parent", :foo)
    assert_raise(TypeError) { os1.dig("child", 0) }
  end

  def test_to_h
    h = {name: "John Smith", age: 70, pension: 300}
    os = BBOpenStruct.new(h)
    to_h = os.to_h
    assert_equal(h, to_h)

    to_h[:age] = 71
    assert_equal(70, os.age)
    assert_equal(70, h[:age])

    assert_equal(h, BBOpenStruct.new("name" => "John Smith", "age" => 70, pension: 300).to_h)
  end

  def test_each_pair # binding returns fields in different order so there are little differences
    h = {name: "John Smith", age: 70, pension: 300}
    os = BBOpenStruct.new(h)
    assert_equal '#<Enumerator: #<BBOpenStruct age=70, name="John Smith", pension=300>:each_pair>', os.each_pair.inspect.force_encoding('UTF-8')
    assert_equal [[:pension, 300], [:age, 70], [:name, "John Smith"]], os.each_pair.to_a
    assert_equal 3, os.each_pair.size
  end

  def test_eql_and_hash
    os1 = BBOpenStruct.new age: 70
    os2 = BBOpenStruct.new age: 70.0
    assert_equal os1, os2
    assert_equal false, os1.eql?(os2)
    assert_not_equal os1.hash, os2.hash
    assert_equal true, os1.eql?(os1.dup)
    assert_equal os1.hash, os1.dup.hash
  end

  def test_method_missing
    os = BBOpenStruct.new
    e = assert_raise(NoMethodError) { os.foo true }
    assert_equal :foo, e.name
    assert_equal [true], e.args
    assert_match(/#{__callee__}/, e.backtrace[0])
    e = assert_raise(ArgumentError) { os.send :foo=, true, true }
  end

  def test_accessor_defines_method
    os = BBOpenStruct.new(foo: 42)
    assert os.respond_to? :foo
    assert_equal(42, os.foo)
    assert_equal([:foo, :foo=], os.singleton_methods.sort)
  end

  def test_does_not_redefine
    os = BBOpenStruct.new(foo: 42)
    def os.foo
      43
    end
    os.foo = 44
    assert_equal(43, os.foo)
  end
end