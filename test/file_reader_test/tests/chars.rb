# frozen_string_literal: true

module FileReaderTest
  module Chars
    def test_chars_is_a_deprecated_alias_for_each_char
      file = file_containing("riroriro")
      enumerator = nil

      _out, err = capture_io {
        enumerator = file.chars
      }

      assert_equal "r", enumerator.next
      assert_equal "i", enumerator.next

      assert_includes err, "warning: "
      assert_includes err, "Tar::FileReader#chars"
      assert_includes err, "deprecated"
      assert_includes err, "#each_char"
    end
  end
end
