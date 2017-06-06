# frozen_string_literal: true

module FileReaderTest
  module Readline
    def test_readline_with_custom_separator
      file = file_containing("tahi+rua-toru*whā/")

      assert_equal "tahi+", file.readline("+")
      assert_equal "rua-", file.readline("-")
      assert_equal "toru*", file.readline("*")
      assert_equal "whā/", file.readline("/")
    end

    def test_readline_with_empty_separator
      file = file_containing("\n\n\n\n\ntahi\nrua\n\n\n\n\ntoru\nwhā\n\n\n\n\n")

      assert_equal "tahi\nrua\n\n", file.readline("")
      assert_equal "toru\nwhā\n\n", file.readline("")
    end

    def test_readline_with_nil_separator
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      assert_equal "tahi\nrua\ntoru\nwhā\n", file.readline(nil)
    end

    def test_readline_with_limit_and_default_separator
      file = file_containing("tahi_rua_toru_whā_")
      lines = []

      with_input_record_separator "_" do
        8.times do
          lines << file.readline(3)
        end
      end

      assert_equal ["tah", "i_", "rua", "_", "tor", "u_", "whā", "_"], lines
    end

    def test_readline_with_limit_and_custom_separator
      file = file_containing("tahi+rua-toru*whā/")

      assert_equal "tah", file.readline("+", 3)
      assert_equal "i+", file.readline("+", 3)
      assert_equal "rua", file.readline("-", 3)
      assert_equal "-", file.readline("-", 3)
      assert_equal "tor", file.readline("*", 3)
      assert_equal "u*", file.readline("*", 3)
      assert_equal "whā", file.readline("/", 3)
      assert_equal "/", file.readline("/", 3)
    end

    def test_readline_with_limit_and_empty_separator
      file = file_containing("\n\n\n\n\ntahi\nrua\n\n\n\n\ntoru\nwhā\n\n\n\n\n")

      assert_equal "tah", file.readline("", 3)
      assert_equal "i\nr", file.readline("", 3)
      assert_equal "ua\n", file.readline("", 3)
      assert_equal "tor", file.readline("", 3)
      assert_equal "u\nw", file.readline("", 3)
      assert_equal "hā", file.readline("", 3)
    end

    def test_readline_with_limit_and_nil_separator
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      assert_equal "tahi\nr", file.readline(nil, 6)
      assert_equal "ua\ntor", file.readline(nil, 6)
      assert_equal "u\nwhā", file.readline(nil, 6)
      assert_equal "\n", file.readline(nil, 6)
    end

    def test_readline_with_nil_limit
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      assert_equal "tahi\n", file.readline("\n", nil)
      assert_equal "rua\n", file.readline("\n", nil)
      assert_equal "toru\n", file.readline("\n", nil)
      assert_equal "whā\n", file.readline("\n", nil)
    end

    def test_readline_with_negative_limit
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      assert_equal "tahi\n", file.readline("\n", -1)
      assert_equal "rua\n", file.readline("\n", -2)
      assert_equal "toru\n", file.readline("\n", -3)
      assert_equal "whā\n", file.readline("\n", -4)
    end

    def test_readline_increments_lineno
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      file.readline
      assert_equal 1, file.lineno
      file.readline
      assert_equal 2, file.lineno
    end

    def test_readline_increments_manually_set_lineno
      file = file_containing("tahi\nrua\ntoru\nwhā\n")
      file.lineno = 42

      file.readline
      assert_equal 43, file.lineno
      file.readline
      assert_equal 44, file.lineno
    end

    def test_readline_with_limit_increments_lineno
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      file.readline 3
      assert_equal 0, file.lineno
      file.readline 3
      assert_equal 1, file.lineno
      file.readline 3
      assert_equal 1, file.lineno
      file.readline 3
      assert_equal 2, file.lineno
    end

    def test_cannot_readline_at_eof
      assert_raises EOFError do
        file_at_eof.readline
      end
    end

    def test_cannot_readline_when_closed
      assert_raises IOError do
        closed_file.readline
      end
    end

    def test_readline_with_too_many_arguments_raises_argument_error_with_correct_backtrace
      exception = assert_raises(ArgumentError) {
        @file.readline("\n", 42, "!")
      }
      assert_includes exception.backtrace.first, "in `readline'"
    end
  end
end
