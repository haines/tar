# frozen_string_literal: true

module FileReaderTest
  module Pending
    def test_cannot_get_pending_when_closed
      assert_raises IOError do
        closed_file.pending
      end
    end
  end
end
