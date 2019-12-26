# frozen_string_literal: true

require_relative "../writer_test"

module WriterTest
  test_underlying "Pipe", unsupported: ["add_without_size"] do
    def setup
      @reader, @io = IO.pipe("binary")
    end

    def read_back
      @reader.read
    end
  end
end
