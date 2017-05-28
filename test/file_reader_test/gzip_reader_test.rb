# frozen_string_literal: true

require_relative "../test_helper"
require_relative "common_tests"
require_relative "read_to_buffer_unsupported_tests"
require_relative "seek_unsupported_tests"
require "zlib"

module FileReaderTest
  class GzipReaderTest < Minitest::Test
    include CommonTests
    include ReadToBufferUnsupportedTests
    include SeekUnsupportedTests

    private

    def io_containing(contents)
      io = StringIO.new
      writer = Zlib::GzipWriter.new(io)
      writer.write("______#{contents}______")
      writer.close

      Zlib::GzipReader.new(StringIO.new(io.string)).tap { |reader| reader.read 6 }
    end
  end
end
