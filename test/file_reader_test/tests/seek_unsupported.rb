# frozen_string_literal: true

module FileReaderTest
  module SeekUnsupported
    def test_cannot_seek_to_absolute_pos
      file = file_containing("takahē")

      assert_raises Tar::SeekNotSupported do
        file.seek 3
      end
    end

    def test_cannot_explicitly_seek_to_absolute_pos_with_constant
      file = file_containing("kākāriki")

      assert_raises Tar::SeekNotSupported do
        file.seek 5, IO::SEEK_SET
      end
    end

    def test_cannot_explicitly_seek_to_absolute_pos_with_symbol
      file = file_containing("mātuhituhi")

      assert_raises Tar::SeekNotSupported do
        file.seek 7, :SET
      end
    end

    def test_cannot_seek_by_relative_offset_with_constant
      file = file_containing("kōkako")
      file.read 4

      assert_raises Tar::SeekNotSupported do
        file.seek 2, IO::SEEK_CUR
      end
    end

    def test_cannot_seek_by_relative_offset_with_symbol
      file = file_containing("pūkeko")
      file.read 6

      assert_raises Tar::SeekNotSupported do
        file.seek(-3, :CUR)
      end
    end

    def test_cannot_seek_from_end_with_constant
      file = file_containing("tītipounamu")

      assert_raises Tar::SeekNotSupported do
        file.seek(-3, IO::SEEK_END)
      end
    end

    def test_cannot_seek_from_end_with_symbol
      file = file_containing("kākā")

      assert_raises Tar::SeekNotSupported do
        file.seek(-2, :END)
      end
    end

    def test_cannot_seek_with_unknown_mode
      file = file_containing("parekareka")

      assert_raises Tar::SeekNotSupported do
        file.seek 42, :NONSENSE
      end
    end

    def test_cannot_seek_when_closed
      assert_raises Tar::SeekNotSupported do
        closed_file.seek 50
      end
    end

    def test_cannot_set_pos
      file = file_containing("pāpango")

      assert_raises Tar::SeekNotSupported do
        file.pos = 8
      end
    end

    def test_cannot_set_pos_when_closed
      assert_raises Tar::SeekNotSupported do
        closed_file.seek 9000
      end
    end

    def test_cannot_rewind
      file = file_containing("mātātā")
      file.read 6

      assert_raises Tar::SeekNotSupported do
        file.rewind
      end
    end

    def test_cannot_rewind_when_closed
      assert_raises Tar::SeekNotSupported do
        closed_file.rewind
      end
    end
  end
end
