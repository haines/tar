# frozen_string_literal: true

require_relative "../writer_test"

module WriterTest
  test_underlying "StringIO" do
    def new_io
      StringIO.new("".b)
    end

    def read_back
      @io.string
    end
  end
end
