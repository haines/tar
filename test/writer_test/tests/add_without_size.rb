# frozen_string_literal: true

module WriterTest
  module AddWithoutSize
    def test_size_may_be_omitted_with_block
      Tar::Writer.new @io do |writer|
        writer.add path: "path/to/first" do |file|
          file.write "tahi"
        end
        writer.add path: "path/to/second" do |file|
          file.write "rua"
        end
      end

      assert_equal "00000000004\0", written[124, 12]
      assert_equal "tahi", written[512, 4]

      assert_equal "00000000003\0", written[1148, 12]
      assert_equal "rua", written[1536, 3]
    end
  end
end
