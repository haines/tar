# frozen_string_literal: true

module FileReaderTest
  module Getbyte
    def test_getbyte
      file = file_containing("pīhoihoi")

      assert_equal 0x70, file.getbyte
      assert_equal 0xC4, file.getbyte
      assert_equal 0xAB, file.getbyte
    end

    def test_getbyte_increments_pos
      file = file_containing("tauhou")

      file.getbyte
      assert_equal 1, file.pos
      file.getbyte
      assert_equal 2, file.pos
    end

    def test_getbyte_at_eof_returns_nil
      assert_nil file_at_eof.getbyte
    end

    def test_cannot_getbyte_when_closed
      assert_raises IOError do
        closed_file.getbyte
      end
    end
  end
end
