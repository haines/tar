# frozen_string_literal: true

module FileReaderTest
  module Bytes
    def test_bytes_is_a_deprecated_alias_for_each_byte
      file = file_containing("kea")
      enumerator = nil

      _out, err = capture_io {
        enumerator = file.bytes
      }

      assert_equal 0x6B, enumerator.next
      assert_equal 0x65, enumerator.next

      assert_includes err, "warning: "
      assert_includes err, "Tar::FileReader#bytes"
      assert_includes err, "deprecated"
      assert_includes err, "#each_byte"
    end
  end
end
