# frozen_string_literal: true

module FileReaderTest
  module Getc
    def test_getc
      file = file_containing("whēkau")

      assert_equal "w", file.getc
      assert_equal "h", file.getc
      assert_equal "ē", file.getc
      assert_equal "k", file.getc
    end

    def test_getc_increments_pos
      file = file_containing("pīwauwau")

      file.getc
      assert_equal 1, file.pos
      file.getc
      assert_equal 3, file.pos
    end

    def test_getc_handles_invalid_encoding
      file = file_containing("h\xC5ōkioi")

      assert_equal "h", file.getc
      assert_equal "\xC5", file.getc
      assert_equal "ō", file.getc
    end

    def test_getc_handles_invalid_encoding_near_eof
      file = file_containing("kāh\xC5u")
      file.read 3

      assert_equal "h", file.getc
      assert_equal "\xC5", file.getc
      assert_equal "u", file.getc
    end

    def test_getc_at_eof_returns_nil
      assert_nil file_at_eof.getc
    end

    def test_cannot_getc_when_closed
      assert_raises IOError do
        closed_file.getc
      end
    end
  end
end
