# frozen_string_literal: true

require_relative "test_helper"
require "tar/reader"

class ReaderTest < Minitest::Test
  def test_read_empty_archive
    archive = empty_archive

    Tar::Reader.new(archive).each do
      flunk "Expected block not to be called."
    end

    assert_eof archive
  end

  def test_read_one_file_archive
    expected_files = { "path/to/file" => "Hello, world!" }
    archive = archive_of(expected_files)

    actual_files = Tar::Reader.new(archive).map { |file|
      [file.header.path, file.read]
    }.to_h

    assert_equal expected_files, actual_files
    assert_eof archive
  end

  def test_read_multiple_file_archive
    expected_files = {
      "path/to/first"  => "tahi",
      "path/to/second" => "rua",
      "path/to/third"  => "toru"
    }
    archive = archive_of(expected_files)

    actual_files = Tar::Reader.new(archive).map { |file|
      [file.header.path, file.read]
    }.to_h

    assert_equal expected_files, actual_files
    assert_eof archive
  end

  def test_attempt_to_read_empty_header
    archive = StringIO.new
    archive.write "\0" * 512
    archive.write ":(" * 256
    archive.rewind

    reader = Tar::Reader.new(archive)

    assert_raises Tar::InvalidArchive do
      reader.each do
        flunk "Expected block not to be called."
      end
    end
  end

  def test_read_with_encoding_options
    archive = archive_of(
      "path/to/first" => "tahi\r\nrua\r\n",
      "path/to/second" => "toru\r\nwh\xE2\r\n"
    )

    reader = Tar::Reader.new(archive, external_encoding: "ISO-8859-13", internal_encoding: "UTF-8", universal_newline: true)

    assert_equal ["tahi\nrua\n", "toru\nwhā\n"], reader.map(&:read)
  end

  private

  def empty_archive
    archive_of({})
  end

  def archive_of(files)
    archive = StringIO.new

    files.each do |path, contents|
      archive.write header(path: path, size: contents.size)
      archive.write contents.ljust(512, "\0")
    end

    archive.write("\0" * 1024)

    archive.rewind

    archive
  end

  def header(path:, size:)
    path.ljust(100, "\0") +       # name
      "000644 \0" +               # mode
      "000123 \0" +               # uid
      "000456 \0" +               # gid
      format("%011o ", size) +    # size
      "13105143071 " +            # mtime
      "013305\0 " +               # checksum
      "0" +                       # typeflag
      "\0" * 100 +                # link_name
      "ustar\0" +                 # magic
      "00" +                      # version
      "haines".ljust(32, "\0") +  # uname
      "staff".ljust(32, "\0") +   # gname
      "000000 \0" +               # dev_major
      "000000 \0" +               # dev_minor
      "\0" * 155 +                # prefix
      "\0" * 12                   # padding
  end

  def assert_eof(archive)
    assert archive.eof?, "Expected archive to have been read to end."
  end
end
