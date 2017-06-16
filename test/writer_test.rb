# frozen_string_literal: true

require_relative "test_helper"
require "tar/writer"

class WriterTest < Minitest::Test
  def test_write_empty_archive
    io = new_io
    writer = Tar::Writer.new(io)

    writer.close

    assert_equal "\0" * 1024, io.string
  end

  def test_write_files_to_archive
    io = new_io
    writer = Tar::Writer.new(io)

    writer.add path: "path/to/first", size: 4 do |file|
      file.write "tahi"
    end

    writer.add path: "path/to/second", size: 3 do |file|
      file.write "rua"
    end

    writer.close

    assert_equal "tahi".ljust(512, "\0"), io.string[512, 512]
    assert_equal "rua".ljust(512, "\0"), io.string[1536, 512]
    assert_equal "\0" * 1024, io.string[2048..-1]
  end

  private

  def new_io
    StringIO.new("".dup.force_encoding("binary"))
  end
end
