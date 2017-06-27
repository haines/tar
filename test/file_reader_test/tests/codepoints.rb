# frozen_string_literal: true

module FileReaderTest
  module Codepoints
    def test_codepoints_is_a_deprecated_alias_for_each_codepoint
      file = file_containing("tāiko")
      enumerator = nil

      _out, err = capture_io {
        enumerator = file.codepoints
      }

      assert_equal 116, enumerator.next
      assert_equal 257, enumerator.next

      assert_includes err, "warning: "
      assert_includes err, "Tar::File::Reader#codepoints"
      assert_includes err, "deprecated"
      assert_includes err, "#each_codepoint"
    end
  end
end
