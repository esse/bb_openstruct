require 'bb_openstruct'
require 'ostruct'
require "benchmark"
require "benchmark/ips"
hash = { a: 10, str: 'a1b2' }

puts 'creation'
Benchmark.ips do |x|
    x.report("BBOpenstruct") { BBOpenStruct.new(hash) }
    x.report("Openstruct") { OpenStruct.new(hash) }
    x.compare!
end

bb_openstruct = BBOpenStruct.new(hash)
struct = OpenStruct.new(hash)
puts 'get'
Benchmark.ips do |x|
  x.report("BBOpenstruct") { bb_openstruct.a; bb_openstruct.str }
  x.report("Openstruct") { struct.a; struct.str }
  x.compare!
end

bb_openstruct = BBOpenStruct.new(hash)
struct = OpenStruct.new(hash)
puts 'set'
Benchmark.ips do |x|
  x.report("BBOpenstruct") { bb_openstruct.a = 2; bb_openstruct.string_2 = 'abc' }
  x.report("Openstruct") { struct.a = 2; struct.string_2 = 'abc' }
  x.compare!
end

bb_openstruct = BBOpenStruct.new(hash)
struct = OpenStruct.new(hash)
puts 'set different'
Benchmark.ips do |x|
  x.report("BBOpenstruct") { bb_openstruct.send("var_#{n}=".to_sym, 1) }
  x.report("Openstruct") { struct.send("var_#{n}=".to_sym, 1) }
  x.compare!
end
