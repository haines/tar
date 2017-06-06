# frozen_string_literal: true

require_relative "../test_helper"
require_relative "define_tests"
require "tempfile"

module FileReaderTest
  define_tests "File" do |contents|
    Tempfile.new("file_reader_test").tap { |file|
      file.write "______#{contents}______"
      file.pos = 6
    }
  end

  class FileTtyTest
    def test_is_a_tty_if_underlying_io_is_a_tty
      file = Tar::FileReader.new(any_header, File.new("/dev/tty"))

      assert file.tty?
    end
  end
end
