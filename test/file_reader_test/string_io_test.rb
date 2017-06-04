# frozen_string_literal: true

require_relative "../test_helper"
require_relative "define_tests"
require "tar/backports"

module FileReaderTest
  using Tar::Backports

  define_tests "StringIO" do |contents|
    StringIO.new(+"______#{contents}______").tap { |io| io.pos = 6 }
  end
end
