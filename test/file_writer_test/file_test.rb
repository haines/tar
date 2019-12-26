# frozen_string_literal: true

require_relative "../file_writer_test"
require "tempfile"

module FileWriterTest
  test_underlying "File" do
    def setup
      @io = Tempfile.new("file_writer_test")
      @io.write "______"
    end

    def read_back
      File.open(@io.path, mode: "rb") do |file|
        file.seek 6
        file.read
      end
    end
  end

  class FileTtyTest
    def test_is_a_tty_if_underlying_io_is_a_tty
      file = Tar::File::Writer.new(io: File.new("/dev/tty"))

      assert file.tty?
    end
  end
end
