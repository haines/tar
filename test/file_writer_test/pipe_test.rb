# frozen_string_literal: true

require_relative "../file_writer_test"

module FileWriterTest
  test_underlying "Pipe", unsupported: ["seek"] do
    def setup
      @reader, @io = IO.pipe("binary")
      @io.write "______"
    end

    def read_back
      @reader.read 6
      @reader.read
    end
  end
end
