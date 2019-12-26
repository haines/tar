# frozen_string_literal: true

module FileReaderTest
  module ExternalEncoding
    def test_a_new_file_has_default_external_encoding
      file = with_default_encoding(external: Encoding::ISO_8859_1) {
        Tar::File::Reader.new(io: any_io, header: any_header)
      }

      assert_equal Encoding::ISO_8859_1, file.external_encoding
    end

    def test_a_new_file_has_external_encoding_from_given_name
      file = Tar::File::Reader.new(io: any_io, header: any_header, external_encoding: "ISO-8859-1")

      assert_equal Encoding::ISO_8859_1, file.external_encoding
    end

    def test_a_new_file_has_external_encoding_from_given_encoding
      file = Tar::File::Reader.new(io: any_io, header: any_header, external_encoding: Encoding::ISO_8859_1)

      assert_equal Encoding::ISO_8859_1, file.external_encoding
    end

    def test_cannot_get_external_encoding_when_closed
      assert_raises IOError do
        closed_file.external_encoding
      end
    end
  end
end
