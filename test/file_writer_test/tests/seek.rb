# frozen_string_literal: true

module FileWriterTest
  module Seek
    def test_seek_backwards_to_absolute_pos
      file = new_file
      file.write "hiraka"

      file.seek 3

      assert_equal 3, file.pos

      file.write "AKA!"

      assert_equal "hirAKA!", written
    end

    def test_seek_forwards_to_absolute_pos
      file = new_file
      file.write "toirua"

      file.seek 8

      assert_equal 8, file.pos

      file.write "RUA!"

      assert_equal "toirua\0\0RUA!", written
    end

    def test_cannot_seek_to_absolute_pos_beyond_start_of_file
      assert_raises Errno::EINVAL do
        new_file.seek(-1)
      end
    end

    def test_explicitly_seek_to_absolute_pos_with_constant
      file = new_file
      file.write "perehere"

      file.seek 4, IO::SEEK_SET

      assert_equal 4, file.pos

      file.write "HE"

      assert_equal "pereHEre", written
    end

    def test_explicitly_seek_to_absolute_pos_with_symbol
      file = new_file
      file.write "oho"

      file.seek 4, :SET

      assert_equal 4, file.pos

      file.write "O"

      assert_equal "oho\0O", written
    end

    # def test_seek_by_relative_offset_with_constant
    #   file = file_containing("kōkako")
    #   file.read 4

    #   file.seek 2, IO::SEEK_CUR

    #   assert_equal 6, file.pos
    #   assert_equal "o", file.read
    # end

    # def test_seek_by_relative_offset_with_symbol
    #   file = file_containing("pūkeko")
    #   file.read 6

    #   file.seek(-3, :CUR)

    #   assert_equal 3, file.pos
    #   assert_equal "keko", file.read
    # end

    # def test_cannot_seek_to_relative_offset_beyond_start_of_file
    #   file = file_containing("kūkūpa")
    #   file.read 1

    #   assert_raises Errno::EINVAL do
    #     file.seek(-2, :CUR)
    #   end
    # end

    # def test_seek_from_end_with_constant
    #   file = file_containing("tītipounamu")

    #   file.seek(-3, IO::SEEK_END)

    #   assert_equal 9, file.pos
    #   assert_equal "amu", file.read
    # end

    # def test_seek_from_end_with_symbol
    #   file = file_containing("kākā")

    #   file.seek(-2, :END)

    #   assert_equal 4, file.pos
    #   assert_equal "ā", file.read
    # end

    # def test_cannot_seek_from_end_beyond_start_of_file
    #   file = file_containing("momohua")

    #   assert_raises Errno::EINVAL do
    #     file.seek(-8, :END)
    #   end
    # end

    def test_seek_with_unknown_mode
      assert_raises ArgumentError do
        new_file.seek 42, :NONSENSE
      end
    end

    def test_cannot_seek_when_closed
      assert_raises IOError do
        closed_file.seek 50
      end
    end

    # def test_set_pos
    #   file = file_containing("pāpango")

    #   file.pos = 7

    #   assert_equal 7, file.pos
    #   assert_equal "o", file.read
    # end

    def test_cannot_set_pos_when_closed
      assert_raises IOError do
        closed_file.pos = 9000
      end
    end

    # def test_rewind_resets_pos
    #   file = file_containing("mātātā")
    #   file.read 6

    #   file.rewind

    #   assert_equal 0, file.pos
    #   assert_equal "mātātā", file.read
    # end

    def test_cannot_rewind_when_closed
      assert_raises IOError do
        closed_file.rewind
      end
    end
  end
end
