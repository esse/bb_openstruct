# BBOpenstruct

This gem contains BBOpenStruct (Binding-based openstruct) class - reimplementation of OpenStruct that uses binding to store your data internally. Why? For science. You monster.

Test file is actually taken from original openstruct implementation, so API is nearly identical.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bb_openstruct'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bb_openstruct

## Usage

Use it like your normal OpenStruct:

    require 'bb_openstruct'
    bb = BBOpenStruct.new(a: 1)
    bb.a # => 1
    bb[:a] # => 1
    bb.new_var = 20
    bb.new_var # => 20

## Should I use it on production

Well... I don't really know what can go wrong, however I'm not sure it's very good idea.

## Benchmarks

    creation
    Openstruct:   719494.0 i/s
    BBOpenstruct:    54072.0 i/s - 13.31x  slower

    get
    Openstruct:  3548217.5 i/s
    BBOpenstruct:  3170859.8 i/s - same-ish: difference falls within error

    set
    BBOpenstruct:  2470835.7 i/s
    Openstruct:  1730367.3 i/s - 1.43x  slower

    set different
    Openstruct:  1163716.8 i/s
    BBOpenstruct:  1145259.5 i/s - same-ish: difference falls within error

(benchmarks code can be found in benchmark.rb file)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

