# frozen_string_literal: true

module FileReaderTest
  module Lines
    def test_lines_is_a_deprecated_alias_for_each_line
      file = file_containing("tahi+rua+toru+whā+")
      enumerator = nil

      _out, err = capture_io {
        enumerator = file.lines("+")
      }

      assert_equal "tahi+", enumerator.next
      assert_equal "rua+", enumerator.next

      assert_includes err, "warning: "
      assert_includes err, "Tar::File::Reader#lines"
      assert_includes err, "deprecated"
      assert_includes err, "#each_line"
    end
  end
end
