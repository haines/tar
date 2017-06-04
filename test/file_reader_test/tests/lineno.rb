# frozen_string_literal: true

module FileReaderTest
  module Lineno
    def test_a_new_file_is_at_lineno_0
      assert_equal 0, new_file.lineno
    end

    def test_lineno_can_be_set_manually
      @file.lineno = 42

      assert_equal 42, @file.lineno
    end

    def test_cannot_get_lineno_when_closed
      assert_raises IOError do
        closed_file.lineno
      end
    end

    def test_cannot_set_lineno_when_closed
      assert_raises IOError do
        closed_file.lineno = 42
      end
    end
  end
end
