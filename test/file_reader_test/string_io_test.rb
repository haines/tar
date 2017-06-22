# frozen_string_literal: true

require_relative "../file_reader_test"

module FileReaderTest
  test_underlying "StringIO" do
    def io_containing(contents)
      StringIO.new(+"______#{contents}______").tap { |io| io.pos = 6 }
    end
  end
end
