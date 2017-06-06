# frozen_string_literal: true

module FileReaderTest
  module EachCodepoint
    def test_each_codepoint
      file = file_containing("tāiko")
      codepoints = []

      file.each_codepoint do |codepoint|
        codepoints << codepoint
      end

      assert_equal [116, 257, 105, 107, 111], codepoints
    end

    def test_each_codepoint_increments_pos
      file = file_containing("tōrea")
      poses = []

      file.each_codepoint do
        poses << file.pos
      end

      assert_equal [1, 3, 4, 5, 6], poses
    end

    def test_each_codepoint_at_eof_does_nothing
      file_at_eof.each_codepoint do
        flunk "Expected block not to be called."
      end
    end

    def test_cannot_enumerate_codepoints_when_closed
      assert_raises IOError do
        closed_file.each_codepoint do
          flunk "Expected block not to be called."
        end
      end
    end

    def test_each_codepoint_returns_enumerator_when_no_block_given
      file = file_containing("tāiko")

      enumerator = file.each_codepoint

      assert_equal 116, enumerator.next
      assert_equal 257, enumerator.next
    end

    def test_cannot_get_codepoint_enumerator_when_closed
      assert_raises IOError do
        closed_file.each_codepoint
      end
    end
  end
end
