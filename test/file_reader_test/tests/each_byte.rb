# frozen_string_literal: true

module FileReaderTest
  module EachByte
    def test_each_byte
      file = file_containing("weweia")
      bytes = []

      file.each_byte do |byte|
        bytes << byte
      end

      assert_equal [0x77, 0x65, 0x77, 0x65, 0x69, 0x61], bytes
    end

    def test_each_byte_increments_pos
      file = file_containing("kakī")
      poses = []

      file.each_byte do
        poses << file.pos
      end

      assert_equal (1..5).to_a, poses
    end

    def test_each_byte_at_eof_does_nothing
      file_at_eof.each_byte do
        flunk "Expected block not to be called."
      end
    end

    def test_cannot_enumerate_bytes_when_closed
      assert_raises IOError do
        closed_file.each_byte do
          flunk "Expected block not to be called."
        end
      end
    end

    def test_each_byte_returns_enumerator_when_no_block_given
      file = file_containing("kea")

      enumerator = file.each_byte

      assert_equal 0x6B, enumerator.next
      assert_equal 0x65, enumerator.next
    end

    def test_cannot_get_byte_enumerator_when_closed
      assert_raises IOError do
        closed_file.each_byte
      end
    end
  end
end
