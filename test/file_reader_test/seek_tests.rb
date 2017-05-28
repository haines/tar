# frozen_string_literal: true

module FileReaderTest
  module SeekTests
    def test_seek_to_absolute_pos
      file = file_containing("takahē")

      file.seek 3

      assert_equal 3, file.pos
      assert_equal "ahē", file.read
    end

    def test_explicitly_seek_to_absolute_pos_with_constant
      file = file_containing("kākāriki")

      file.seek 5, IO::SEEK_SET

      assert_equal 5, file.pos
      assert_equal "\x81riki", file.read
    end

    def test_explicitly_seek_to_absolute_pos_with_symbol
      file = file_containing("mātuhituhi")

      file.seek 7, :SET

      assert_equal 7, file.pos
      assert_equal "tuhi", file.read
    end

    def test_seek_by_relative_offset_with_constant
      file = file_containing("kōkako")
      file.read 4

      file.seek 2, IO::SEEK_CUR

      assert_equal 6, file.pos
      assert_equal "o", file.read
    end

    def test_seek_by_relative_offset_with_symbol
      file = file_containing("pūkeko")
      file.read 6

      file.seek(-3, :CUR)

      assert_equal 3, file.pos
      assert_equal "keko", file.read
    end

    def test_seek_from_end_with_constant
      file = file_containing("tītipounamu")

      file.seek(-3, IO::SEEK_END)

      assert_equal 9, file.pos
      assert_equal "amu", file.read
    end

    def test_seek_from_end_with_symbol
      file = file_containing("kākā")

      file.seek(-2, :END)

      assert_equal 4, file.pos
      assert_equal "ā", file.read
    end

    def test_seek_with_unknown_mode
      file = file_containing("parekareka")

      assert_raises ArgumentError do
        file.seek 42, :NONSENSE
      end
    end

    def test_cannot_seek_when_closed
      assert_raises IOError do
        closed_file.seek 50
      end
    end

    def test_set_pos
      file = file_containing("pāpango")

      file.pos = 7

      assert_equal 7, file.pos
      assert_equal "o", file.read
    end

    def test_cannot_set_pos_when_closed
      assert_raises IOError do
        closed_file.seek 9000
      end
    end

    def test_rewind_resets_pos
      file = file_containing("mātātā")
      file.read 6

      file.rewind

      assert_equal 0, file.pos
      assert_equal "mātātā", file.read
    end

    def test_rewind_resets_lineno
      file = file_containing("kōtuku")
      file.lineno = 11

      file.rewind

      assert_equal 0, file.lineno
    end

    def test_cannot_rewind_when_closed
      assert_raises IOError do
        closed_file.rewind
      end
    end
  end
end
