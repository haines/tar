# frozen_string_literal: true

module FileReaderTest
  module Ungetbyte
    def test_ungetbyte
      file = file_containing("koekoeā")
      file.read 4

      file.ungetbyte 0x21

      assert_equal "!oeā", file.read
    end

    def test_ungetbyte_at_start_of_file
      file = file_containing("pōpokotea")

      file.ungetbyte 0x2B

      assert_equal "+pōpokotea", file.read
    end

    def test_ungetbyte_at_end_of_file
      file = file_at_eof

      file.ungetbyte 0x2D

      refute file.eof?
      assert_equal "-", file.read
    end

    def test_ungetbyte_decrements_pos
      file = file_containing("ngutuparore")
      file.read 7

      file.ungetbyte 0x7E

      assert_equal 6, file.pos
    end

    def test_cannot_ungetbyte_when_closed
      assert_raises IOError do
        closed_file.ungetbyte 0x3D
      end
    end
  end
end
