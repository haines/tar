# frozen_string_literal: true

module FileReaderTest
  module SetEncoding
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

    def test_external_encoding_may_be_set_to_utf_8_by_bom
      file = file_containing("\xEF\xBB\xBFtarapirohe")

      file.set_encoding "BOM|US-ASCII"

      assert_equal Encoding::UTF_8, file.external_encoding
      assert_equal "tarapirohe", file.read
    end

    def test_external_encoding_handles_partial_utf_8_bom
      file = file_containing("\xEF\xBBhōkioi")

      file.set_encoding "BOM|US-ASCII"

      assert_equal Encoding::US_ASCII, file.external_encoding
      assert_equal us_ascii("\xEF\xBBh\xC5\x8Dkioi"), file.read
    end

    def test_external_encoding_may_be_set_to_utf_16_be_by_bom
      file = file_containing("\xFE\xFF\0r\0a\0n\0g\0u\0r\0u")

      file.set_encoding "BOM|US-ASCII:UTF-8"

      assert_equal Encoding::UTF_16BE, file.external_encoding
      assert_equal "ranguru", file.read
    end

    def test_external_encoding_handles_partial_utf_16_be_bom
      file = file_containing("\xFEpihipihi")

      file.set_encoding "BOM|US-ASCII"

      assert_equal Encoding::US_ASCII, file.external_encoding
      assert_equal us_ascii("\xFEpihipihi"), file.read
    end

    def test_external_encoding_may_be_set_to_utf_16_le_by_bom
      file = file_containing("\xFF\xFEt\0o\0u\0t\0o\0u\0w\0a\0i\0")

      file.set_encoding "BOM|US-ASCII:UTF-8"

      assert_equal Encoding::UTF_16LE, file.external_encoding
      assert_equal "toutouwai", file.read
    end

    def test_external_encoding_handles_partial_utf_16_le_bom
      file = file_containing("\xFFkakaruwai")

      file.set_encoding "BOM|US-ASCII"

      assert_equal Encoding::US_ASCII, file.external_encoding
      assert_equal us_ascii("\xFFkakaruwai"), file.read
    end

    def test_external_encoding_may_be_set_to_utf_32_be_by_bom
      file = file_containing("\0\0\xFE\xFF\0\0\0k\0\0\0o\0\0\0r\0\0\0o\0\0\0r\0\0\x01\x01")

      file.set_encoding "BOM|US-ASCII:UTF-8"

      assert_equal Encoding::UTF_32BE, file.external_encoding
      assert_equal "kororā", file.read
    end

    def test_external_encoding_handles_partial_utf_32_be_bom
      file = file_containing("\0\0\xFEkuaka")

      file.set_encoding "BOM|US-ASCII"

      assert_equal Encoding::US_ASCII, file.external_encoding
      assert_equal us_ascii("\0\0\xFEkuaka"), file.read
    end

    def test_external_encoding_may_be_set_to_utf_32_le_by_bom
      file = file_containing("\xFF\xFE\0\0t\0\0\0\x6B\x01\0\0t\0\0\0u\0\0\0r\0\0\0u\0\0\0a\0\0\0t\0\0\0u\0\0\0")

      file.set_encoding "BOM|US-ASCII:UTF-8"

      assert_equal Encoding::UTF_32LE, file.external_encoding
      assert_equal "tūturuatu", file.read
    end

    def test_external_encoding_handles_partial_utf_32_le_bom
      file = file_containing("\xFF\xFE\0\x03h\0u\0r\0u\0p\0o\0u\0n\0a\0m\0u\0")

      file.set_encoding "BOM|US-ASCII:UTF-8"

      assert_equal Encoding::UTF_16LE, file.external_encoding
      assert_equal "\u0300hurupounamu", file.read
    end

    def test_external_encoding_falls_back_to_given_encoding_when_bom_is_absent
      file = file_containing("tuke")

      file.set_encoding "BOM|US-ASCII"

      assert_equal Encoding::US_ASCII, file.external_encoding
      assert_equal us_ascii("tuke"), file.read
    end

    def test_external_encoding_falls_back_to_given_encoding_when_not_at_start_of_file
      file = file_containing("\xEF\xBB\xBFmiro\xEF\xBB\xBFmiro")

      file.read 7
      file.set_encoding "BOM|US-ASCII"

      assert_equal Encoding::US_ASCII, file.external_encoding
      assert_equal us_ascii("\xEF\xBB\xBFmiro"), file.read
    end

    def test_cannot_set_encoding_when_closed
      assert_raises IOError do
        closed_file.set_encoding "ISO-8859-13", "UTF-8"
      end
    end
  end
end
