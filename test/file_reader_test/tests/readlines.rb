# frozen_string_literal: true

module FileReaderTest
  module Readlines
    def test_readlines_with_default_separator
      file = file_containing("tahi_rua_toru_whā_")

      lines = with_input_record_separator("_") {
        file.readlines
      }

      assert_equal ["tahi_", "rua_", "toru_", "whā_"], lines
    end

    def test_readlines_with_custom_separator
      file = file_containing("tahi+rua+toru+whā+")

      assert_equal ["tahi+", "rua+", "toru+", "whā+"], file.readlines("+")
    end

    def test_readlines_with_empty_separator
      file = file_containing("\n\n\n\n\ntahi\nrua\n\n\n\n\ntoru\nwhā\n\n\n\n\n")

      assert_equal ["tahi\nrua\n\n", "toru\nwhā\n\n"], file.readlines("")
    end

    def test_readlines_with_nil_separator
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      assert_equal ["tahi\nrua\ntoru\nwhā\n"], file.readlines("")
    end

    def test_readlines_with_limit_and_default_separator
      file = file_containing("tahi_rua_toru_whā_")

      lines = with_input_record_separator("_") {
        file.readlines(3)
      }

      assert_equal ["tah", "i_", "rua", "_", "tor", "u_", "whā", "_"], lines
    end

    def test_readlines_with_limit_and_custom_separator
      file = file_containing("tahi+rua+toru+whā+")

      assert_equal ["tah", "i+", "rua", "+", "tor", "u+", "whā", "+"], file.readlines("+", 3)
    end

    def test_readlines_with_limit_and_empty_separator
      file = file_containing("\n\n\n\n\ntahi\nrua\n\n\n\n\ntoru\nwhā\n\n\n\n\n")

      assert_equal ["tah", "i\nr", "ua\n", "tor", "u\nw", "hā"], file.readlines("", 3)
    end

    def test_readlines_with_limit_and_nil_separator
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      assert_equal ["tahi\nr", "ua\ntor", "u\nwhā", "\n"], file.readlines(nil, 6)
    end

    def test_readlines_with_nil_limit
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      assert_equal ["tahi\n", "rua\n", "toru\n", "whā\n"], file.readlines("\n", nil)
    end

    def test_readlines_with_negative_limit
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      assert_equal ["tahi\n", "rua\n", "toru\n", "whā\n"], file.readlines("\n", -42)
    end

    def test_readlines_increments_lineno
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      file.readlines

      assert_equal 4, file.lineno
    end

    def test_readlines_increments_manually_set_lineno
      file = file_containing("tahi\nrua\ntoru\nwhā\n")
      file.lineno = 42

      file.readlines

      assert_equal 46, file.lineno
    end

    def test_readlines_with_limit_increments_lineno
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      file.readlines 3

      assert_equal 4, file.lineno
    end

    def test_readlines_at_eof_does_nothing
      file_at_eof.readlines do
        flunk "Expected block not to be called."
      end
    end

    def test_cannot_readlines_when_closed
      assert_raises IOError do
        closed_file.readlines do
          flunk "Expected block not to be called."
        end
      end
    end
  end
end
