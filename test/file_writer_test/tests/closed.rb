# frozen_string_literal: true

module FileWriterTest
  module Closed
    def test_a_new_file_is_not_closed
      refute new_file.closed?
    end

    def test_a_closed_file_is_closed
      assert closed_file.closed?
    end

    def test_closed_if_underlying_io_closed
      file = Tar::File::Writer.new(io: @io)

      @io.close

      assert file.closed?
    end
  end
end
