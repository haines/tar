# frozen_string_literal: true

require_relative "../file_writer_test"

module FileWriterTest
  test_underlying "StringIO" do
    def setup
      @io = StringIO.new("".b)
      @io.write "______"
    end

    def read_back
      @io.string[6..-1]
    end
  end
end
