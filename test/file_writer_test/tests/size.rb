# frozen_string_literal: true

module FileWriterTest
  module Size
    def test_fixed_size
      file = new_file(size: 42)
      file.write "kātaitai"

      assert_equal 42, file.size
    end

    def test_variable_size
      file = new_file
      file.write "pīpipi"

      assert_equal 7, file.size
    end
  end
end
