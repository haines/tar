# frozen_string_literal: true

require_relative "../test_helper"
require_relative "common_tests"
require "tempfile"

module FileReaderTest
  class FileTest < Minitest::Test
    include CommonTests

    def test_is_a_tty_if_underlying_io_is_a_tty
      file = Tar::FileReader.new(any_header, File.new("/dev/tty"))

      assert file.tty?
    end

    private

    def io_containing(contents)
      Tempfile.new("file_reader_test").tap { |file|
        file.write "______#{contents}______"
        file.pos = 6
      }
    end
  end
end
