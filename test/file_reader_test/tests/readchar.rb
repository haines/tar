# frozen_string_literal: true

module FileReaderTest
  module Readchar
    def test_readchar
      file = file_containing("whēkau")

      assert_equal "w", file.readchar
      assert_equal "h", file.readchar
      assert_equal "ē", file.readchar
      assert_equal "k", file.readchar
    end

    def test_readchar_increments_pos
      file = file_containing("pīwauwau")

      file.readchar
      assert_equal 1, file.pos
      file.readchar
      assert_equal 3, file.pos
    end

    def test_readchar_handles_invalid_encoding
      file = file_containing("h\xC5ōkioi")

      assert_equal "h", file.readchar
      assert_equal "\xC5", file.readchar
      assert_equal "ō", file.readchar
    end

    def test_readchar_handles_invalid_encoding_near_eof
      file = file_containing("kāh\xC5u")
      file.read 3

      assert_equal "h", file.readchar
      assert_equal "\xC5", file.readchar
      assert_equal "u", file.readchar
    end

    def test_cannot_readchar_at_eof
      assert_raises EOFError do
        file_at_eof.readchar
      end
    end

    def test_cannot_readchar_when_closed
      assert_raises IOError do
        closed_file.readchar
      end
    end
  end
end
