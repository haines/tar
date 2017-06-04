# frozen_string_literal: true

module FileReaderTest
  module EachChar
    def test_each_char
      file = file_containing("mohua")
      chars = []

      file.each_char do |char|
        chars << char
      end

      assert_equal ["m", "o", "h", "u", "a"], chars
    end

    def test_each_char_increments_pos
      file = file_containing("pūweto")
      poses = []

      file.each_char do
        poses << file.pos
      end

      assert_equal [1, 3, 4, 5, 6, 7].to_a, poses
    end

    def test_each_char_at_eof_does_nothing
      file_at_eof.each_char do
        flunk "Expected block not to be called."
      end
    end

    def test_cannot_enumerate_chars_when_closed
      assert_raises IOError do
        closed_file.each_char do
          flunk "Expected block not to be called."
        end
      end
    end

    def test_each_char_returns_enumerator_when_no_block_given
      file = file_containing("riroriro")

      enumerator = file.each_char

      assert_equal "r", enumerator.next
      assert_equal "i", enumerator.next
    end

    def test_cannot_get_char_enumerator_when_closed
      assert_raises IOError do
        closed_file.each_char
      end
    end
  end
end
