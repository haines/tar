# frozen_string_literal: true

module FileReaderTest
  module Readpartial
    def test_readpartial
      file = file_containing("moa")

      assert_equal "mo", file.readpartial(2)
    end

    def test_readpartial_changes_pos
      file = file_containing("korimako")

      file.readpartial 2
      assert_equal 2, file.pos
      file.readpartial 2
      assert_equal 4, file.pos
    end

    def test_readpartial_beyond_eof_returns_shorter_string_than_requested
      file = file_containing("tīeke")
      file.readpartial 3

      assert_equal "eke", file.readpartial(42)
    end

    def test_readpartial_beyond_eof_sets_pos_to_eof
      file = file_containing("hihi")

      file.readpartial 42

      assert_equal 4, file.pos
    end

    def test_readpartial_at_eof_returns_empty_string
      assert_equal "", file_at_eof.readpartial(9000)
    end

    def test_readpartial_returns_binary_regardless_of_encoding_options
      file = file_containing("tūī", external_encoding: "UTF-8")

      assert_equal binary("t\xC5\xAB"), file.readpartial(3)
    end

    def test_readpartial_to_buffer
      file = file_containing("pūtangitangi")
      buffer = +"this data will be overwritten"

      file.readpartial 5, buffer

      assert_equal binary("p\xC5\xABta"), buffer
    end

    def test_cannot_readpartial_when_closed
      assert_raises IOError do
        closed_file.readpartial(99)
      end
    end
  end
end
