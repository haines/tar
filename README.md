# Tar

[![Build Status](https://travis-ci.org/haines/tar.svg?branch=master)](https://travis-ci.org/haines/tar)
[![Code Climate](https://codeclimate.com/github/haines/tar/badges/gpa.svg)](https://codeclimate.com/github/haines/tar)

Read and write tar files with Ruby.


## Installation

Add this line to your application's Gemfile:

```ruby
gem "tar"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tar


## Usage

### Reading tar files

Tar files can be read from IO streams, for example `File`s or `Zlib::GzipReader`s, using a `Tar::Reader`.
For example, to print the contents of the archive to stdout:

```ruby
require "tar/reader"

File.open "example.tar" do |archive|
  Tar::Reader.new(archive).each do |file|
    puts "==> #{file.header.path} (#{file.header.size} bytes)"
    puts file.read
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake test` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/haines/tar.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
