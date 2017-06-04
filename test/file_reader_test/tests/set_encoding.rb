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

    def test_cannot_set_encoding_when_closed
      assert_raises IOError do
        closed_file.set_encoding "ISO-8859-13", "UTF-8"
      end
    end
  end
end
