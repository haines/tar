# frozen_string_literal: true

module FileReaderTest
  module Gets
    def test_gets_with_default_separator
      file = file_containing("tahi_rua_toru_whā_")
      lines = []

      with_input_record_separator "_" do
        4.times do
          lines << file.gets
        end
      end

      assert_equal ["tahi_", "rua_", "toru_", "whā_"], lines
    end

    def test_gets_with_custom_separator
      file = file_containing("tahi+rua-toru*whā/")

      assert_equal "tahi+", file.gets("+")
      assert_equal "rua-", file.gets("-")
      assert_equal "toru*", file.gets("*")
      assert_equal "whā/", file.gets("/")
    end

    def test_gets_with_empty_separator
      file = file_containing("\n\n\n\n\ntahi\nrua\n\n\n\n\ntoru\nwhā\n\n\n\n\n")

      assert_equal "tahi\nrua\n\n", file.gets("")
      assert_equal "toru\nwhā\n\n", file.gets("")
      assert file.eof?
    end

    def test_gets_with_nil_separator
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      assert_equal "tahi\nrua\ntoru\nwhā\n", file.gets(nil)
    end

    def test_gets_with_limit_and_default_separator
      file = file_containing("tahi_rua_toru_whā_")
      lines = []

      with_input_record_separator "_" do
        8.times do
          lines << file.gets(3)
        end
      end

      assert_equal ["tah", "i_", "rua", "_", "tor", "u_", "whā", "_"], lines
    end

    def test_gets_with_limit_and_custom_separator
      file = file_containing("tahi+rua-toru*whā/")

      assert_equal "tah", file.gets("+", 3)
      assert_equal "i+", file.gets("+", 3)
      assert_equal "rua", file.gets("-", 3)
      assert_equal "-", file.gets("-", 3)
      assert_equal "tor", file.gets("*", 3)
      assert_equal "u*", file.gets("*", 3)
      assert_equal "whā", file.gets("/", 3)
      assert_equal "/", file.gets("/", 3)
    end

    def test_gets_with_limit_and_empty_separator
      file = file_containing("\n\n\n\n\ntahi\nrua\n\n\n\n\ntoru\nwhā\n\n\n\n\n")

      assert_equal "tah", file.gets("", 3)
      assert_equal "i\nr", file.gets("", 3)
      assert_equal "ua\n", file.gets("", 3)
      assert_equal "tor", file.gets("", 3)
      assert_equal "u\nw", file.gets("", 3)
      assert_equal "hā", file.gets("", 3)
    end

    def test_gets_with_limit_and_nil_separator
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      assert_equal "tahi\nr", file.gets(nil, 6)
      assert_equal "ua\ntor", file.gets(nil, 6)
      assert_equal "u\nwhā", file.gets(nil, 6)
      assert_equal "\n", file.gets(nil, 6)
    end

    def test_gets_with_nil_limit
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      assert_equal "tahi\n", file.gets("\n", nil)
      assert_equal "rua\n", file.gets("\n", nil)
      assert_equal "toru\n", file.gets("\n", nil)
      assert_equal "whā\n", file.gets("\n", nil)
    end

    def test_gets_with_negative_limit
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      assert_equal "tahi\n", file.gets("\n", -1)
      assert_equal "rua\n", file.gets("\n", -2)
      assert_equal "toru\n", file.gets("\n", -3)
      assert_equal "whā\n", file.gets("\n", -4)
    end

    def test_gets_increments_lineno
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      file.gets
      assert_equal 1, file.lineno
      file.gets
      assert_equal 2, file.lineno
    end

    def test_gets_increments_manually_set_lineno
      file = file_containing("tahi\nrua\ntoru\nwhā\n")
      file.lineno = 42

      file.gets
      assert_equal 43, file.lineno
      file.gets
      assert_equal 44, file.lineno
    end

    def test_gets_with_limit_increments_lineno
      file = file_containing("tahi\nrua\ntoru\nwhā\n")

      file.gets 3
      assert_equal 0, file.lineno
      file.gets 3
      assert_equal 1, file.lineno
      file.gets 3
      assert_equal 1, file.lineno
      file.gets 3
      assert_equal 2, file.lineno
    end

    def test_gets_at_eof_returns_nil
      assert_nil file_at_eof.gets
    end

    def test_cannot_gets_when_closed
      assert_raises IOError do
        closed_file.gets
      end
    end

    def test_gets_with_too_many_arguments_raises_argument_error
      assert_raises(ArgumentError) do
        @file.gets("\n", 42, "!")
      end
    end
  end
end
