# frozen_string_literal: true

require_relative "../writer_test"
require "zlib"

module WriterTest
  test_underlying "GzipWriter", unsupported: ["add_without_size"] do
    def new_io
      @string_io = StringIO.new("".b)
      Zlib::GzipWriter.new(@string_io)
    end

    def read_back
      Zlib::GzipReader.new(StringIO.new(@string_io.string)).read.b
    end
  end
end
