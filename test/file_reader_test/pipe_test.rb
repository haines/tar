# frozen_string_literal: true

require_relative "../file_reader_test"

module FileReaderTest
  test_underlying "Pipe", unsupported: ["seek"] do
    def io_containing(contents)
      reader, writer = IO.pipe

      writer.write "______#{contents}______"
      writer.close

      reader.read 6
      reader
    end
  end

  class PipeReadpartialTest
    def test_readpartial_reads_available_bytes_without_blocking
      reader, writer = IO.pipe
      file = Tar::File::Reader.new(io: reader, header: header(size: 42))
      writer.write "pātātai"

      assert_equal "p\xC4\x81t\xC4\x81tai".b, file.readpartial(42)
    end
  end
end
