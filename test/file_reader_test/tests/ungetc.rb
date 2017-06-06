# frozen_string_literal: true

module FileReaderTest
  module Ungetc
    def test_ungetc
      file = file_containing("kuruwhengu")
      file.read 5

      file.ungetc "ā"

      assert_equal "āhengu", file.read
    end

    def test_ungetc_with_different_external_encoding
      file = file_containing("t\xEEtiti", external_encoding: "ISO-8859-13")
      file.read 1

      file.ungetc "ē"

      assert_equal iso_8859_13("\xE7\xEEtiti"), file.read
    end

    def test_ungetc_with_multiple_chars
      file = file_containing("pāteke")
      file.read 4

      file.ungetc "koitar"

      assert_equal "koitareke", file.read
    end

    def test_ungetc_at_start_of_file
      file = file_containing("pokotiwha")

      file.ungetc "ī"

      assert_equal "īpokotiwha", file.read
    end

    def test_ungetc_at_end_of_file
      file = file_at_eof

      file.ungetc "ō"

      refute file.eof?
      assert_equal "ō", file.read
    end

    def test_ungetc_decrements_pos
      file = file_containing("karuwai")
      file.read 3

      file.ungetc "ū"

      assert_equal 1, file.pos
    end

    def test_cannot_ungetc_when_closed
      assert_raises IOError do
        closed_file.ungetc "!"
      end
    end
  end
end
