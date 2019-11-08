# frozen_string_literal: true

require_relative "../writer_test"
require "zlib"

module WriterTest
  test_underlying "GzipWriter", unsupported: ["add_without_size"] do
    def setup
      @string_io = StringIO.new
      @io = Zlib::GzipWriter.new(@string_io)
    end

    def read_back
      Zlib::GzipReader.new(StringIO.new(@string_io.string), encoding: "binary").read
    end
  end
end
