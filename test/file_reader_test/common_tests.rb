# frozen_string_literal: true

require "tar/backports"
require "tar/file_reader"

module FileReaderTest
  module CommonTests
    using Tar::Backports

    def setup
      @file = Tar::FileReader.new(any_header, any_io)
    end

    def test_a_new_file_is_not_closed
      refute @file.closed?
    end

    def test_closed_after_close
      @file.close

      assert @file.closed?
    end

    def test_closed_if_underlying_io_closed
      io = any_io
      file = Tar::FileReader.new(any_header, io)

      io.close

      assert file.closed?
    end

    def test_read_without_internal_encoding
      file = file_containing("kākāpō", external_encoding: "UTF-8", internal_encoding: nil)

      assert_equal "kākāpō", file.read
    end

    def test_read_with_internal_encoding
      file = file_containing("p\xEEwakawaka", external_encoding: "ISO-8859-13", internal_encoding: "UTF-8")

      assert_equal "pīwakawaka", file.read
    end

    def test_read_with_encoding_options
      file = file_containing("hoiho\r\ntawaki\r\n", external_encoding: "UTF-8", internal_encoding: "UTF-8", universal_newline: true)

      assert_equal "hoiho\ntawaki\n", file.read
    end

    def test_read_changes_pos
      file = file_containing("kererū")

      file.read

      assert_equal 7, file.pos
    end

    def test_read_leaves_file_at_eof
      file = file_containing("whio")

      file.read

      assert file.eof?
    end

    def test_read_at_eof_returns_empty_string
      assert_equal "", file_at_eof.read
    end

    def test_partial_read
      file = file_containing("moa")

      assert_equal "mo", file.read(2)
    end

    def test_partial_read_changes_pos
      file = file_containing("korimako")

      file.read 2
      assert_equal 2, file.pos
      file.read 2
      assert_equal 4, file.pos
    end

    def test_partial_read_beyond_eof_returns_shorter_string_than_requested
      file = file_containing("tīeke")
      file.read 3

      assert_equal "eke", file.read(42)
    end

    def test_partial_read_beyond_eof_sets_pos_to_eof
      file = file_containing("hihi")

      file.read 42

      assert_equal 4, file.pos
    end

    def test_partial_read_at_eof_returns_empty_string
      assert_equal "", file_at_eof.read(9000)
    end

    def test_partial_read_returns_binary_regardless_of_encoding_options
      file = file_containing("tūī", external_encoding: "UTF-8")

      assert_equal binary("t\xC5\xAB"), file.read(3)
    end

    def test_cannot_read_when_closed
      assert_raises IOError do
        closed_file.read
      end
    end

    def test_cannot_get_pos_when_closed
      assert_raises IOError do
        closed_file.pos
      end
    end

    def test_cannot_get_eof_when_closed
      assert_raises IOError do
        closed_file.eof?
      end
    end

    def test_cannot_get_pending_when_closed
      assert_raises IOError do
        closed_file.pending
      end
    end

    def test_a_new_file_has_default_encodings
      file = with_default_encoding(external: "ISO-8859-1", internal: "Windows-1252") {
        Tar::FileReader.new(any_header, any_io)
      }

      assert_equal Encoding::ISO_8859_1, file.external_encoding
      assert_equal Encoding::WINDOWS_1252, file.internal_encoding
    end

    def test_a_new_file_may_have_specified_encodings
      file = Tar::FileReader.new(any_header, any_io, external_encoding: "ISO-8859-1", internal_encoding: "Windows-1252")

      assert_equal Encoding::ISO_8859_1, file.external_encoding
      assert_equal Encoding::WINDOWS_1252, file.internal_encoding
    end

    def test_external_encoding_may_be_a_string
      @file.set_encoding "ISO-8859-1"

      assert_equal Encoding::ISO_8859_1, @file.external_encoding
    end

    def test_external_encoding_may_be_an_encoding
      @file.set_encoding Encoding::ISO_8859_1

      assert_equal Encoding::ISO_8859_1, @file.external_encoding
    end

    def test_fall_back_to_default_when_external_encoding_is_nil
      with_default_encoding external: "ISO-8859-1", internal: "Windows-1252" do
        @file.set_encoding nil
      end

      assert_equal Encoding::ISO_8859_1, @file.external_encoding
    end

    def test_fall_back_to_default_when_external_encoding_is_empty
      with_default_encoding external: "ISO-8859-1", internal: "Windows-1252" do
        @file.set_encoding ""
      end

      assert_equal Encoding::ISO_8859_1, @file.external_encoding
    end

    def test_fall_back_to_default_and_warn_if_external_encoding_does_not_exist
      _out, err = capture_io {
        with_default_encoding external: "ISO-8859-1", internal: "Windows-1252" do
          @file.set_encoding "WTF-8"
        end
      }

      assert_includes err, "warning: "
      assert_includes err, "WTF-8"
      assert_includes err, "ISO-8859-1"

      assert_equal Encoding::ISO_8859_1, @file.external_encoding
    end

    def test_internal_encoding_may_be_explicitly_set_to_nil
      with_default_encoding external: "ISO-8859-1", internal: "Windows-1252" do
        @file.set_encoding "US-ASCII", nil
      end

      assert_nil @file.internal_encoding
    end

    def test_internal_encoding_may_be_implicitly_set_to_nil
      with_default_encoding external: "ISO-8859-1", internal: "Windows-1252" do
        @file.set_encoding "US-ASCII"
      end

      assert_nil @file.internal_encoding
    end

    def test_internal_encoding_may_be_set_to_nil_with_empty_string
      with_default_encoding external: "ISO-8859-1", internal: "Windows-1252" do
        @file.set_encoding "US-ASCII", ""
      end

      assert_nil @file.internal_encoding
    end

    def test_internal_encoding_may_be_a_string
      @file.set_encoding "ISO-8859-1", "Windows-1252"

      assert_equal Encoding::WINDOWS_1252, @file.internal_encoding
    end

    def test_internal_encoding_may_be_an_encoding
      @file.set_encoding "ISO-8859-1", Encoding::WINDOWS_1252

      assert_equal Encoding::WINDOWS_1252, @file.internal_encoding
    end

    def test_fall_back_to_default_and_warn_if_internal_encoding_does_not_exist
      _out, err = capture_io {
        with_default_encoding external: "ISO-8859-1", internal: "Windows-1252" do
          @file.set_encoding "US-ASCII", "WTF-8"
        end
      }

      assert_includes err, "warning: "
      assert_includes err, "WTF-8"
      assert_includes err, "Windows-1252"

      assert_equal Encoding::WINDOWS_1252, @file.internal_encoding
    end

    def test_external_and_internal_encodings_may_be_given_in_one_string
      @file.set_encoding "ISO-8859-1:Windows-1252"

      assert_equal Encoding::ISO_8859_1, @file.external_encoding
      assert_equal Encoding::WINDOWS_1252, @file.internal_encoding
    end

    def test_binmode
      @file.binmode

      assert_equal Encoding::BINARY, @file.external_encoding
      assert_nil @file.internal_encoding
      assert @file.binmode?
    end

    def test_binmode_when_equivalent_settings_applied_manually
      @file.set_encoding "binary", nil

      assert @file.binmode?
    end

    def test_binmode_even_with_encoding_options
      # no transcoding is performed when internal_encoding is nil, so options are irrelevant
      @file.set_encoding "binary", nil, universal_newline: true

      assert @file.binmode?
    end

    def test_cannot_get_external_encoding_when_closed
      assert_raises IOError do
        closed_file.external_encoding
      end
    end

    def test_cannot_get_internal_encoding_when_closed
      assert_raises IOError do
        closed_file.internal_encoding
      end
    end

    def test_cannot_set_encoding_when_closed
      assert_raises IOError do
        closed_file.set_encoding "ISO-8859-13", "UTF-8"
      end
    end

    def test_cannot_get_binmode_when_closed
      assert_raises IOError do
        closed_file.binmode?
      end
    end

    def test_cannot_set_binmode_when_closed
      assert_raises IOError do
        closed_file.binmode
      end
    end

    def test_is_not_a_tty_if_underlying_io_is_not_a_tty
      file = Tar::FileReader.new(any_header, io_containing("not a tty!"))

      refute file.tty?
    end

    def test_cannot_get_tty_when_closed
      assert_raises IOError do
        closed_file.tty?
      end
    end

    def test_a_new_file_is_at_pos_0
      assert_equal 0, @file.pos
    end

    def test_a_new_file_is_at_lineno_0
      assert_equal 0, @file.lineno
    end

    def test_skip_to_next_record
      io = io_containing("ruru".ljust(512, "\0"))
      file = Tar::FileReader.new(header(size: 4), io)
      file.read

      file.skip_to_next_record

      assert_equal 512, file.pos
      assert file.eof?
      assert_equal 518, io.pos
    end

    def test_getbyte
      file = file_containing("pīhoihoi")

      assert_equal 0x70, file.getbyte
      assert_equal 0xC4, file.getbyte
      assert_equal 0xAB, file.getbyte
    end

    def test_getbyte_increments_pos
      file = file_containing("tauhou")

      file.getbyte
      assert_equal 1, file.pos
      file.getbyte
      assert_equal 2, file.pos
    end

    def test_getbyte_at_eof_returns_nil
      assert_nil file_at_eof.getbyte
    end

    def test_cannot_getbyte_when_closed
      assert_raises IOError do
        closed_file.getbyte
      end
    end

    def test_ungetbyte
      file = file_containing("koekoeā")
      file.read 4

      file.ungetbyte 0x21

      assert_equal "!oeā", file.read
    end

    def test_ungetbyte_at_start_of_file
      file = file_containing("pōpokotea")

      file.ungetbyte 0x2B

      assert_equal "+pōpokotea", file.read
    end

    def test_ungetbyte_at_end_of_file
      file = file_at_eof

      file.ungetbyte 0x2D

      refute file.eof?
      assert_equal "-", file.read
    end

    def test_ungetbyte_decrements_pos
      file = file_containing("ngutuparore")
      file.read 7

      file.ungetbyte 0x7E

      assert_equal 6, file.pos
    end

    def test_cannot_ungetbyte_when_closed
      assert_raises IOError do
        closed_file.ungetbyte 0x3D
      end
    end

    def test_readbyte
      file = file_containing("pīhoihoi")

      assert_equal 0x70, file.readbyte
      assert_equal 0xC4, file.readbyte
      assert_equal 0xAB, file.readbyte
    end

    def test_readbyte_increments_pos
      file = file_containing("tauhou")

      file.readbyte
      assert_equal 1, file.pos
      file.readbyte
      assert_equal 2, file.pos
    end

    def test_cannot_readbyte_at_eof
      assert_raises EOFError do
        file_at_eof.readbyte
      end
    end

    def test_cannot_readbyte_when_closed
      assert_raises IOError do
        closed_file.readbyte
      end
    end

    def test_each_byte
      file = file_containing("weweia")
      bytes = []

      file.each_byte do |byte|
        bytes << byte
      end

      assert_equal [0x77, 0x65, 0x77, 0x65, 0x69, 0x61], bytes
    end

    def test_each_byte_increments_pos
      file = file_containing("kakī")
      poses = []

      file.each_byte do
        poses << file.pos
      end

      assert_equal (1..5).to_a, poses
    end

    def test_each_byte_at_eof_does_nothing
      file_at_eof.each_byte do
        flunk "Expected block not to be called."
      end
    end

    def test_cannot_enumerate_bytes_when_closed
      assert_raises IOError do
        closed_file.each_byte do
          flunk "Expected block not to be called."
        end
      end
    end

    def test_each_byte_returns_enumerator_when_no_block_given
      file = file_containing("kea")

      enumerator = file.each_byte

      assert_equal 0x6B, enumerator.next
      assert_equal 0x65, enumerator.next
    end

    def test_cannot_get_byte_enumerator_when_closed
      assert_raises IOError do
        closed_file.each_byte
      end
    end

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

    def test_getc
      file = file_containing("whēkau")

      assert_equal "w", file.getc
      assert_equal "h", file.getc
      assert_equal "ē", file.getc
      assert_equal "k", file.getc
    end

    def test_getc_increments_pos
      file = file_containing("pīwauwau")

      file.getc
      assert_equal 1, file.pos
      file.getc
      assert_equal 3, file.pos
    end

    def test_getc_at_eof_returns_nil
      assert_nil file_at_eof.getc
    end

    def test_cannot_getc_when_closed
      assert_raises IOError do
        closed_file.getc
      end
    end

    def test_getc_handles_invalid_encoding
      file = file_containing("h\xC5ōkioi")

      assert_equal "h", file.getc
      assert_equal "\xC5", file.getc
      assert_equal "ō", file.getc
    end

    def test_getc_handles_invalid_encoding_near_eof
      file = file_containing("kāh\xC5u")
      file.read 3

      assert_equal "h", file.getc
      assert_equal "\xC5", file.getc
      assert_equal "u", file.getc
    end

    def test_ungetc
      file = file_containing("kuruwhengu")
      file.read 5

      file.ungetc "ā"

      assert_equal "āhengu", file.read
    end

    def test_ungetc_with_different_external_encoding
      file = file_containing("t\xEEtiti", external_encoding: "ISO-8859-13")
      file.read 1

      file.ungetc "ē"

      assert_equal iso_8859_13("\xE7\xEEtiti"), file.read
    end

    def test_ungetc_with_multiple_chars
      file = file_containing("pāteke")
      file.read 4

      file.ungetc "koitar"

      assert_equal "koitareke", file.read
    end

    def test_ungetc_at_start_of_file
      file = file_containing("pokotiwha")

      file.ungetc "ī"

      assert_equal "īpokotiwha", file.read
    end

    def test_ungetc_at_end_of_file
      file = file_at_eof

      file.ungetc "ō"

      refute file.eof?
      assert_equal "ō", file.read
    end

    def test_ungetc_decrements_pos
      file = file_containing("karuwai")
      file.read 3

      file.ungetc "ū"

      assert_equal 1, file.pos
    end

    def test_cannot_ungetc_when_closed
      assert_raises IOError do
        closed_file.ungetc "!"
      end
    end

    def test_readchar
      file = file_containing("whēkau")

      assert_equal "w", file.readchar
      assert_equal "h", file.readchar
      assert_equal "ē", file.readchar
      assert_equal "k", file.readchar
    end

    def test_readchar_increments_pos
      file = file_containing("pīwauwau")

      file.readchar
      assert_equal 1, file.pos
      file.readchar
      assert_equal 3, file.pos
    end

    def test_cannot_readchar_at_eof
      assert_raises EOFError do
        file_at_eof.readchar
      end
    end

    def test_cannot_readchar_when_closed
      assert_raises IOError do
        closed_file.readchar
      end
    end

    def test_readchar_handles_invalid_encoding
      file = file_containing("h\xC5ōkioi")

      assert_equal "h", file.readchar
      assert_equal "\xC5", file.readchar
      assert_equal "ō", file.readchar
    end

    def test_readchar_handles_invalid_encoding_near_eof
      file = file_containing("kāh\xC5u")
      file.read 3

      assert_equal "h", file.readchar
      assert_equal "\xC5", file.readchar
      assert_equal "u", file.readchar
    end

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

    def test_codepoints_is_a_deprecated_alias_for_each_codepoint
      file = file_containing("tāiko")
      enumerator = nil

      _out, err = capture_io {
        enumerator = file.codepoints
      }

      assert_equal 116, enumerator.next
      assert_equal 257, enumerator.next

      assert_includes err, "warning: "
      assert_includes err, "Tar::FileReader#codepoints"
      assert_includes err, "deprecated"
      assert_includes err, "#each_codepoint"
    end

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
      file = file_containing("tahi\n\nrua\n\ntoru\n\nwhā\n\n")

      assert_equal "tahi\n\n", file.gets("")
      assert_equal "rua\n\n", file.gets("")
      assert_equal "toru\n\n", file.gets("")
      assert_equal "whā\n\n", file.gets("")
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
      file = file_containing("tahi\n\nrua\n\ntoru\n\nwhā\n\n")

      assert_equal "tah", file.gets("", 3)
      assert_equal "i\n\n", file.gets("", 3)
      assert_equal "rua", file.gets("", 3)
      assert_equal "\n\n", file.gets("", 3)
      assert_equal "tor", file.gets("", 3)
      assert_equal "u\n\n", file.gets("", 3)
      assert_equal "whā", file.gets("", 3)
      assert_equal "\n\n", file.gets("", 3)
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

    def test_gets_with_too_many_arguments_raises_argument_error_with_correct_backtrace
      exception = assert_raises(ArgumentError) {
        @file.gets("\n", 42, "!")
      }

      assert_includes exception.backtrace.first, "in `gets'"
    end

    def test_readline_with_custom_separator
      file = file_containing("tahi+rua-toru*whā/")

      assert_equal "tahi+", file.readline("+")
      assert_equal "rua-", file.readline("-")
      assert_equal "toru*", file.readline("*")
      assert_equal "whā/", file.readline("/")
    end

    def test_readline_with_empty_separator
      file = file_containing("tahi\n\nrua\n\ntoru\n\nwhā\n\n")

      assert_equal "tahi\n\n", file.readline("")
      assert_equal "rua\n\n", file.readline("")
      assert_equal "toru\n\n", file.readline("")
      assert_equal "whā\n\n", file.readline("")
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
      file = file_containing("tahi\n\nrua\n\ntoru\n\nwhā\n\n")

      assert_equal "tah", file.readline("", 3)
      assert_equal "i\n\n", file.readline("", 3)
      assert_equal "rua", file.readline("", 3)
      assert_equal "\n\n", file.readline("", 3)
      assert_equal "tor", file.readline("", 3)
      assert_equal "u\n\n", file.readline("", 3)
      assert_equal "whā", file.readline("", 3)
      assert_equal "\n\n", file.readline("", 3)
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
      file = file_containing("tahi\n\nrua\n\ntoru\n\nwhā\n\n")
      lines = []

      file.each_line "" do |line|
        lines << line
      end

      assert_equal ["tahi\n\n", "rua\n\n", "toru\n\n", "whā\n\n"], lines
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
      file = file_containing("tahi\n\nrua\n\ntoru\n\nwhā\n\n")
      lines = []

      file.each_line "", 3 do |line|
        lines << line
      end

      assert_equal ["tah", "i\n\n", "rua", "\n\n", "tor", "u\n\n", "whā", "\n\n"], lines
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

    def test_each_line_with_too_many_arguments_raises_argument_error_with_correct_backtrace
      exception = assert_raises(ArgumentError) {
        @file.each_line "\n", 42, "!" do
          flunk "Expected block not to be called."
        end
      }

      assert_includes exception.backtrace.first, "in `each_line'"
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

    def test_lines_is_a_deprecated_alias_for_each_line
      file = file_containing("tahi+rua+toru+whā+")
      enumerator = nil

      _out, err = capture_io {
        enumerator = file.lines("+")
      }

      assert_equal "tahi+", enumerator.next
      assert_equal "rua+", enumerator.next

      assert_includes err, "warning: "
      assert_includes err, "Tar::FileReader#lines"
      assert_includes err, "deprecated"
      assert_includes err, "#each_line"
    end

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
      file = file_containing("tahi\n\nrua\n\ntoru\n\nwhā\n\n")

      assert_equal ["tahi\n\n", "rua\n\n", "toru\n\n", "whā\n\n"], file.readlines("")
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
      file = file_containing("tahi\n\nrua\n\ntoru\n\nwhā\n\n")

      assert_equal ["tah", "i\n\n", "rua", "\n\n", "tor", "u\n\n", "whā", "\n\n"], file.readlines("", 3)
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

    private

    def header(size:)
      FakeHeader.new(size)
    end

    def any_header
      header(size: 3)
    end

    def any_io
      io_containing("...")
    end

    def file_containing(contents, **options)
      Tar::FileReader.new(header(size: contents.bytesize), io_containing(contents), **options)
    end

    def closed_file
      Tar::FileReader.new(any_header, any_io).tap(&:close)
    end

    def file_at_eof
      file_containing("...").tap { |file| file.read 3 }
    end

    def binary(string)
      string.dup.force_encoding("binary")
    end

    def iso_8859_13(string)
      string.dup.force_encoding("ISO-8859-13")
    end

    def with_input_record_separator(input_record_separator)
      previous_input_record_separator = $INPUT_RECORD_SEPARATOR
      $INPUT_RECORD_SEPARATOR = input_record_separator
      yield
    ensure
      $INPUT_RECORD_SEPARATOR = previous_input_record_separator
    end

    def with_default_encoding(external:, internal:)
      previous_external = Encoding.default_external
      previous_internal = Encoding.default_internal

      silence_warnings do
        Encoding.default_external = external
        Encoding.default_internal = internal
      end

      yield
    ensure
      silence_warnings do
        Encoding.default_external = previous_external
        Encoding.default_internal = previous_internal
      end
    end

    def silence_warnings
      previous_verbose = $VERBOSE
      $VERBOSE = false
      yield
    ensure
      $VERBOSE = previous_verbose
    end

    FakeHeader = Struct.new(:size)
  end
end
