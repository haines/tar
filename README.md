# Tar

[![Latest version](https://img.shields.io/gem/v/tar.svg?style=flat-square)](https://rubygems.org/gems/tar)&nbsp;
[![Travis CI status](https://img.shields.io/travis/haines/tar.svg?style=flat-square)](https://travis-ci.org/haines/tar)&nbsp;
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/haines/tar?style=flat-square)](https://codeclimate.com/github/haines/tar)&nbsp;
[![Code Climate coverage](https://img.shields.io/codeclimate/coverage/haines/tar?style=flat-square)](https://codeclimate.com/github/haines/tar/code)&nbsp;

Read and write tar files with Ruby.


## Installation

Add this line to your application's Gemfile:

```ruby
gem "tar"
```

And then execute:

```console
$ bundle
```

Or install it yourself as:

```console
$ gem install tar
```


## Usage

### Reading tar files

Tar files can be read from IO streams, for example `File`s or `Zlib::GzipReader`s, using a `Tar::Reader`.
For example, to print the contents of the archive to stdout:

```ruby
require "tar/reader"

File.open "example.tar", "rb" do |archive|
  Tar::Reader.new(archive).each do |file|
    puts "==> #{file.header.path} (#{file.header.size} bytes)"
    puts file.read
  end
end
```

### Writing tar files

Tar files can be written to IO streams, for example `File`s or `Zlib::GzipWriter`s, using a `Tar::Writer`.
For example:

```ruby
require "tar/writer"

File.open "example.tar", "wb" do |archive|
  Tar::Writer.new(archive) do |writer|
    writer.add path: "path/to/file" do |file|
      file.puts "Hello, world!"
    end
  end
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `bin/rake` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bin/rake install`.
To release a new version, update the version number in `version.rb`, and then run `bin/rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/haines/tar.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
