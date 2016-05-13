[![Build Status](https://travis-ci.org/leonardoalifraco/wordpress_util.svg?branch=master)](https://travis-ci.org/leonardoalifraco/wordpress_util)

# WordpressUtil

Group of util and formatting methods defined in Wordpress and ported to Ruby.

This gem includes:
 - wpautop

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wordpress_util'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wordpress_util

## Usage

### wpautop

Replaces double line-breaks with paragraph elements.
A group of regex replaces used to identify text formatted with newlines and
replace double line-breaks with HTML paragraph tags. The remaining line-breaks
after conversion become <br /> tags, unless br is set to '0' or 'false'.

```ruby
WordpressUtil.wpautop("some text")
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/leonardoalifraco/wordpress_util. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

