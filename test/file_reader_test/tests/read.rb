# frozen_string_literal: true

module FileReaderTest
  module Read
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

      assert_equal "t\xC5\xAB".b, file.read(3)
    end

    def test_cannot_read_when_closed
      assert_raises IOError do
        closed_file.read
      end
    end
  end
end
