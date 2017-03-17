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

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

