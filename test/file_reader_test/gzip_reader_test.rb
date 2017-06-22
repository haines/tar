# frozen_string_literal: true

require_relative "../file_reader_test"
require "zlib"

module FileReaderTest
  test_underlying "GzipReader", unsupported: ["read_to_buffer", "seek"] do
    def io_containing(contents)
      io = StringIO.new
      writer = Zlib::GzipWriter.new(io)
      writer.write("______#{contents}______")
      writer.close

      Zlib::GzipReader.new(StringIO.new(io.string)).tap { |reader| reader.read 6 }
    end
  end
end
