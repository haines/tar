# frozen_string_literal: true

module FileReaderTest
  module SkipToNextRecord
    def test_skip_to_next_record
      io = io_containing("ruru".ljust(512, "\0"))
      file = Tar::FileReader.new(header(size: 4), io)
      file.read

      file.skip_to_next_record

      assert_equal 512, file.pos
      assert file.eof?
      assert_equal 518, io.pos
    end

    def test_cannot_skip_to_next_record_when_closed
      assert_raises IOError do
        closed_file.skip_to_next_record
      end
    end
  end
end
