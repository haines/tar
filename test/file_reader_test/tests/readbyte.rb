# frozen_string_literal: true

module FileReaderTest
  module Readbyte
    def test_readbyte
      file = file_containing("pīhoihoi")

      assert_equal 0x70, file.readbyte
      assert_equal 0xC4, file.readbyte
      assert_equal 0xAB, file.readbyte
    end

    def test_readbyte_increments_pos
      file = file_containing("tauhou")

      file.readbyte
      assert_equal 1, file.pos
      file.readbyte
      assert_equal 2, file.pos
    end

    def test_cannot_readbyte_at_eof
      assert_raises EOFError do
        file_at_eof.readbyte
      end
    end

    def test_cannot_readbyte_when_closed
      assert_raises IOError do
        closed_file.readbyte
      end
    end
  end
end
