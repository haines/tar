# frozen_string_literal: true

module WriterTest
  module AddWithoutSizeUnsupported
    def test_size_may_not_be_omitted_with_block
      assert_raises Tar::SeekNotSupported do
        Tar::Writer.new @io do |writer|
          writer.add path: "path/to/first" do |file|
            file.write "tahi"
          end
        end
      end
    end
  end
end
