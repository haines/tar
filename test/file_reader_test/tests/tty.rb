# frozen_string_literal: true

module FileReaderTest
  module Tty
    def test_is_not_a_tty_if_underlying_io_is_not_a_tty
      file = Tar::FileReader.new(any_header, io_containing("not a tty!"))

      refute file.tty?
    end

    def test_cannot_get_tty_when_closed
      assert_raises IOError do
        closed_file.tty?
      end
    end
  end
end
