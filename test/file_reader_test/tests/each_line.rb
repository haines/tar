# frozen_string_literal: true

module FileReaderTest
  module EachLine
    def test_each_line_with_default_separator
      file = file_containing("tahi_rua_toru_whā_")
      lines = []

      with_input_record_separator "_" do
        file.each_line do |line|
          lines << line
        end
      end

      assert_equal ["tahi_", "rua_", "toru_", "whā_"], lines
    end

    def test_each_line_with_custom_separator
      file = file_containing("tahi+rua+toru+whā+")
      lines = []

      file.each_line "+" do |line|
        lines << line
      end

      assert_equal ["tahi+", "rua+", "toru+", "whā+"], lines
    end

    def test_each_line_with_empty_separator
      file = file_containing("\n\n\n\n\ntahi\nrua\n\n\n\n\ntoru\nwhā\n\n\n\n\n")
      lines = []

      file.each_line "" do |line|
        lines << line
      end

      assert_equal ["tahi\nrua\n\n", "toru\nwhā\n\n"], lines
    end

    def test_each_line_with_nil_separator
      file = file_containing("tahi\nrua\ntoru\nwhā\n")
      lines = []

      file.each_line "" do |line|
        lines << line
      end

      assert_equal ["tahi\nrua\ntoru\nwhā\n"], lines
    end

    def test_each_line_with_limit_and_default_separator
      file = file_containing("tahi_rua_toru_whā_")
      lines = []

      with_input_record_separator "_" do
        file.each_line 3 do |line|
          lines << line
        end
      end

      assert_equal ["tah", "i_", "rua", "_", "tor", "u_", "whā", "_"], lines
    end

    def test_each_line_with_limit_and_custom_separator
      file = file_containing("tahi+rua+toru+whā+")
      lines = []

      file.each_line "+", 3 do |line|
        lines << line
      end

      assert_equal ["tah", "i+", "rua", "+", "tor", "u+", "whā", "+"], lines
    end

    def test_each_line_with_limit_and_empty_separator
      file = file_containing("\n\n\n\n\ntahi\nrua\n\n\n\n\ntoru\nwhā\n\n\n\n\n")
      lines = []

      file.each_line "", 3 do |line|
        lines << line
      end

      assert_equal ["tah", "i\nr", "ua\n", "tor", "u\nw", "hā"], lines
    end

    def test_each_line_with_limit_and_nil_separator
      file = file_containing("tahi\nrua\ntoru\nwhā\n")
      lines = []

      file.each_line nil, 6 do |line|
        lines << line
      end

      assert_equal ["tahi\nr", "ua\ntor", "u\nwhā", "\n"], lines
    end

    def test_each_line_with_nil_limit
      file = file_containing("tahi\nrua\ntoru\nwhā\n")
      lines = []

      file.each_line "\n", nil do |line|
        lines << line
      end

      assert_equal ["tahi\n", "rua\n", "toru\n", "whā\n"], lines
    end

    def test_each_line_with_negative_limit
      file = file_containing("tahi\nrua\ntoru\nwhā\n")
      lines = []

      file.each_line "\n", -42 do |line|
        lines << line
      end

      assert_equal ["tahi\n", "rua\n", "toru\n", "whā\n"], lines
    end

    def test_each_line_increments_lineno
      file = file_containing("tahi\nrua\ntoru\nwhā\n")
      linenos = []

      file.each_line do
        linenos << file.lineno
      end

      assert_equal (1..4).to_a, linenos
    end

    def test_each_line_increments_manually_set_lineno
      file = file_containing("tahi\nrua\ntoru\nwhā\n")
      file.lineno = 42
      linenos = []

      file.each_line do
        linenos << file.lineno
      end

      assert_equal (43..46).to_a, linenos
    end

    def test_each_line_with_limit_increments_lineno
      file = file_containing("tahi\nrua\ntoru\nwhā\n")
      linenos = []

      file.each_line 3 do
        linenos << file.lineno
      end

      assert_equal [0, 1, 1, 2, 2, 3, 3, 4], linenos
    end

    def test_each_line_at_eof_does_nothing
      file_at_eof.each_line do
        flunk "Expected block not to be called."
      end
    end

    def test_cannot_enumerate_lines_when_closed
      assert_raises IOError do
        closed_file.each_line do
          flunk "Expected block not to be called."
        end
      end
    end

    def test_each_line_with_too_many_arguments_raises_argument_error
      assert_raises(ArgumentError) do
        @file.each_line "\n", 42, "!" do
          flunk "Expected block not to be called."
        end
      end
    end

    def test_each_line_returns_enumerator_when_no_block_given
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      enumerator = file.each_line

      assert_equal "tahi\n", enumerator.next
      assert_equal "rua\n", enumerator.next
      assert_equal "toru\n", enumerator.next
      assert_equal "whā\n", enumerator.next
    end

    def test_cannot_get_line_enumerator_when_closed
      assert_raises IOError do
        closed_file.each_line
      end
    end
  end
end
