# frozen_string_literal: true

require_relative "../writer_test"

module WriterTest
  test_underlying "Pipe", unsupported: ["add_without_size"] do
    def new_io
      @reader, writer = IO.pipe
      writer
    end

    def read_back
      @reader.read.b
    end
  end
end
