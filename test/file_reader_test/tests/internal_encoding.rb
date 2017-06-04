# frozen_string_literal: true

module FileReaderTest
  module InternalEncoding
    def test_a_new_file_has_default_internal_encoding
      file = with_default_encoding(internal: Encoding::ISO_8859_1) {
        Tar::FileReader.new(any_header, any_io)
      }

      assert_equal Encoding::ISO_8859_1, file.internal_encoding
    end

    def test_a_new_file_has_internal_encoding_from_given_name
      file = Tar::FileReader.new(any_header, any_io, internal_encoding: "ISO-8859-1")

      assert_equal Encoding::ISO_8859_1, file.internal_encoding
    end

    def test_a_new_file_has_internal_encoding_from_given_encoding
      file = Tar::FileReader.new(any_header, any_io, internal_encoding: Encoding::ISO_8859_1)

      assert_equal Encoding::ISO_8859_1, file.internal_encoding
    end

    def test_cannot_get_internal_encoding_when_closed
      assert_raises IOError do
        closed_file.internal_encoding
      end
    end
  end
end
