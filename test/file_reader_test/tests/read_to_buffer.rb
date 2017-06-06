# frozen_string_literal: true

require "tar/backports"

module FileReaderTest
  module ReadToBuffer
    using Tar::Backports

    def test_read_to_buffer_without_internal_encoding
      file = file_containing("k\xE2rearea", external_encoding: "ISO-8859-13")
      buffer = +"this data will be overwritten"

      file.read nil, buffer

      assert_equal iso_8859_13("k\xE2rearea"), buffer
    end

    def test_read_to_buffer_with_internal_encoding
      file = file_containing("t\xFBturiwhatu", external_encoding: "ISO-8859-13", internal_encoding: "UTF-8")
      buffer = +"this data will be overwritten"

      file.read nil, buffer

      assert_equal "tūturiwhatu", buffer
    end

    def test_partial_read_to_buffer
      file = file_containing("pūtangitangi")
      buffer = +"this data will be overwritten"

      file.read 5, buffer

      assert_equal binary("p\xC5\xABta"), buffer
    end
  end
end
