# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "simplecov"
SimpleCov.start do
  add_filter "/lib/char_size.rb"
  add_filter "/test/"
end

require "minitest/autorun"
