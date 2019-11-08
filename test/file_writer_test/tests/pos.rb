# frozen_string_literal: true

module FileWriterTest
  module Pos
    def test_a_new_file_is_at_pos_0
      assert_equal 0, new_file.pos
    end

    def test_cannot_get_pos_when_closed
      assert_raises IOError do
        closed_file.pos
      end
    end
  end
end
