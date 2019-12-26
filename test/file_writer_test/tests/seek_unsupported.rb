# frozen_string_literal: true

module FileWriterTest
  module SeekUnsupported
    def test_cannot_seek_to_absolute_pos
      assert_raises Tar::SeekNotSupported do
        new_file.seek 3
      end
    end

    def test_cannot_explicitly_seek_to_absolute_pos_with_constant
      assert_raises Tar::SeekNotSupported do
        new_file.seek 5, IO::SEEK_SET
      end
    end

    def test_cannot_explicitly_seek_to_absolute_pos_with_symbol
      assert_raises Tar::SeekNotSupported do
        new_file.seek 7, :SET
      end
    end

    def test_cannot_seek_by_relative_offset_with_constant
      assert_raises Tar::SeekNotSupported do
        new_file.seek 2, IO::SEEK_CUR
      end
    end

    def test_cannot_seek_by_relative_offset_with_symbol
      file = new_file
      file.write "pūkeko"

      assert_raises Tar::SeekNotSupported do
        file.seek(-3, :CUR)
      end
    end

    def test_cannot_seek_from_end_with_constant
      file = new_file
      file.write "tītipounamu"

      assert_raises Tar::SeekNotSupported do
        file.seek(-3, IO::SEEK_END)
      end
    end

    def test_cannot_seek_from_end_with_symbol
      file = new_file
      file.write "kākā"

      assert_raises Tar::SeekNotSupported do
        file.seek(-2, :END)
      end
    end

    def test_cannot_seek_with_unknown_mode
      assert_raises Tar::SeekNotSupported do
        new_file.seek 42, :NONSENSE
      end
    end

    def test_cannot_seek_when_closed
      assert_raises Tar::SeekNotSupported do
        closed_file.seek 50
      end
    end

    def test_cannot_set_pos
      assert_raises Tar::SeekNotSupported do
        new_file.pos = 8
      end
    end

    def test_cannot_set_pos_when_closed
      assert_raises Tar::SeekNotSupported do
        closed_file.pos = 9000
      end
    end

    def test_cannot_rewind
      assert_raises Tar::SeekNotSupported do
        new_file.rewind
      end
    end

    def test_cannot_rewind_when_closed
      assert_raises Tar::SeekNotSupported do
        closed_file.rewind
      end
    end
  end
end
