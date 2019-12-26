# frozen_string_literal: true

module WriterTest
  module Close
    def test_write_empty_archive
      writer = Tar::Writer.new(@io)

      writer.close

      assert_equal "\0" * 1024, written
    end

    def test_closed_after_close
      writer = Tar::Writer.new(@io)

      writer.close

      assert writer.closed?
    end

    def test_closes_automatically_if_block_given_to_new
      yielded = nil
      writer = Tar::Writer.new(@io) { |arg| yielded = arg }

      assert_same writer, yielded
      assert writer.closed?
      assert_equal "\0" * 1024, written
    end
  end
end
