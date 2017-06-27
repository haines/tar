# frozen_string_literal: true

require_relative "../file_reader_test"
require "tempfile"

module FileReaderTest
  test_underlying "File" do
    def io_containing(contents)
      Tempfile.new("file_reader_test").tap { |file|
        file.write "______#{contents}______"
        file.pos = 6
      }
    end
  end

  class FileTtyTest
    def test_is_a_tty_if_underlying_io_is_a_tty
      file = Tar::File::Reader.new(io: File.new("/dev/tty"), header: any_header)

      assert file.tty?
    end
  end
end
