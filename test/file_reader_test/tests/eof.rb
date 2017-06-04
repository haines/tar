# frozen_string_literal: true

module FileReaderTest
  module Eof
    def test_cannot_get_eof_when_closed
      assert_raises IOError do
        closed_file.eof?
      end
    end
  end
end
