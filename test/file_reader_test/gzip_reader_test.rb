# frozen_string_literal: true

require_relative "../test_helper"
require_relative "define_tests"
require "zlib"

module FileReaderTest
  define_tests "GzipReader", unsupported: ["read_to_buffer", "seek"] do |contents|
    io = StringIO.new
    writer = Zlib::GzipWriter.new(io)
    writer.write("______#{contents}______")
    writer.close

    Zlib::GzipReader.new(StringIO.new(io.string)).tap { |reader| reader.read 6 }
  end
end
