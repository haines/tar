# frozen_string_literal: true

require "tar/backports"

module FileReaderTest
  module ReadToBufferUnsupported
    using Tar::Backports

    def test_cannot_read_to_buffer_without_internal_encoding
      file = file_containing("k\xE2rearea", external_encoding: "ISO-8859-13")
      buffer = +"this data will not be overwritten"

      assert_raises ArgumentError do
        file.read nil, buffer
      end
    end

    def test_cannot_read_to_buffer_with_internal_encoding
      file = file_containing("t\xFBturiwhatu", external_encoding: "ISO-8859-13", internal_encoding: "UTF-8")
      buffer = +"this data will not be overwritten"

      assert_raises ArgumentError do
        file.read nil, buffer
      end
    end

    def test_cannot_partial_read_to_buffer
      file = file_containing("pūtangitangi")
      buffer = +"this data will not be overwritten"

      assert_raises ArgumentError do
        file.read 5, buffer
      end
    end
  end
end
