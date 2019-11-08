# frozen_string_literal: true

require_relative "../file_writer_test"
require "zlib"

module FileWriterTest
  test_underlying "GzipWriter", unsupported: ["seek"] do
    def setup
      @string_io = StringIO.new("".b)
      @io = Zlib::GzipWriter.new(@string_io)
      @io.write "______"
    end

    def read_back
      reader = Zlib::GzipReader.new(StringIO.new(@string_io.string))
      reader.read 6
      reader.read.b
    end
  end
end
