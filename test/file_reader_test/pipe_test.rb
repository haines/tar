# frozen_string_literal: true

require_relative "../test_helper"
require_relative "define_tests"

module FileReaderTest
  define_tests "Pipe", unsupported: ["seek"] do |contents|
    reader, writer = IO.pipe

    writer.write "______#{contents}______"
    writer.close

    reader.read 6
    reader
  end

  class PipeReadpartialTest
    def test_readpartial_reads_available_bytes_without_blocking
      reader, writer = IO.pipe
      file = Tar::FileReader.new(header(size: 42), reader)
      writer.write "pātātai"

      assert_equal binary("p\xC4\x81t\xC4\x81tai"), file.readpartial(42)
    end
  end
end
