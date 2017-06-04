# frozen_string_literal: true

module FileReaderTest
  module Binmode
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
  end
end
