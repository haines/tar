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

    writer.add(
      path: "path/to/first",
      size: 4,
      mode: 0o770,
      uid: 123,
      uname: "onetwothree",
      gid: 456,
      gname: "fourfivesix",
      mtime: Time.at(1_500_000_000),
      type_flag: "5",
      link_name: nil,
      dev_major: 7,
      dev_minor: 8
    ) do |file|
      file.write "tahi"
    end

    writer.add(
      path: "path/to/second",
      size: 3,
      mode: 0o640,
      uid: 100,
      uname: "onehundred",
      gid: 200,
      gname: "twohundred",
      mtime: Time.at(1_000_000_000),
      type_flag: "2",
      link_name: "linked/path",
      dev_major: 300,
      dev_minor: 400
    ) do |file|
      file.write "rua"
    end

    writer.close

    assert_equal "path/to/first".ljust(100, "\0") +   # name
                 "0000770\0" +                        # mode
                 "0000173\0" +                        # uid
                 "0000710\0" +                        # gid
                 "00000000004\0" +                    # size
                 "13132027400\0" +                    # mtime
                 "0016474\0" +                        # checksum
                 "5" +                                # type_flag
                 "\0" * 100 +                         # link_name
                 "ustar\0" +                          # magic
                 "00" +                               # version
                 "onetwothree".ljust(32, "\0") +      # uname
                 "fourfivesix".ljust(32, "\0") +      # gname
                 "0000007\0" +                        # dev_major
                 "0000010\0" +                        # dev_minor
                 "\0" * 155 +                         # prefix
                 "\0" * 12,                           # padding
                 io.string[0, 512]

    assert_equal "tahi".ljust(512, "\0"), io.string[512, 512]

    assert_equal "path/to/second".ljust(100, "\0") +  # name
                 "0000640\0" +                        # mode
                 "0000144\0" +                        # uid
                 "0000310\0" +                        # gid
                 "00000000003\0" +                    # size
                 "07346545000\0" +                    # mtime
                 "0020357\0" +                        # checksum
                 "2" +                                # type_flag
                 "linked/path".ljust(100, "\0") +     # link_name
                 "ustar\0" +                          # magic
                 "00" +                               # version
                 "onehundred".ljust(32, "\0") +       # uname
                 "twohundred".ljust(32, "\0") +       # gname
                 "0000454\0" +                        # dev_major
                 "0000620\0" +                        # dev_minor
                 "\0" * 155 +                         # prefix
                 "\0" * 12,                           # padding
                 io.string[1024, 512]

    assert_equal "rua".ljust(512, "\0"), io.string[1536, 512]

    assert_equal "\0" * 1024, io.string[2048..-1]
  end

  def test_closed_after_close
    io = new_io
    writer = Tar::Writer.new(io)

    writer.close

    assert writer.closed?
  end

  def test_size_is_zero_when_no_block_given
    io = new_io
    writer = Tar::Writer.new(io)

    writer.add path: "empty/file"

    writer.close

    assert_equal "00000000000\0", io.string[124, 12]
    assert_equal "\0" * 1024, io.string[512..-1]
  end

  def test_cannot_add_files_after_close
    io = new_io
    writer = Tar::Writer.new(io)

    writer.close

    assert_raises IOError do
      writer.add path: "path/to/file", size: 42 do
        flunk "Expected block not to be called."
      end
    end
  end

  def test_closes_automatically_if_block_given_to_new
    io = new_io

    writer = Tar::Writer.new(io) { |w| w.add path: "path/to/file" }

    assert writer.closed?
    assert_equal 1536, io.string.length
  end

  def test_file_contents_may_be_passed_as_a_string
    io = new_io

    Tar::Writer.new io do |writer|
      writer.add path: "path/to/file", contents: "kāmana"
    end

    assert_equal "00000000007\0", io.string[124, 12]
    assert_equal "k\xC4\x81mana".b, io.string[512, 7]
  end

  def test_block_and_contents_string_are_mutually_exclusive
    assert_raises ArgumentError do
      Tar::Writer.new new_io do |writer|
        writer.add path: "path/to/file", contents: "matuku" do
          flunk "Expected block not to be called."
        end
      end
    end
  end

  def test_size_may_be_omitted_with_block
    io = new_io

    Tar::Writer.new io do |writer|
      writer.add path: "path/to/first" do |file|
        file.write "tahi"
      end
      writer.add path: "path/to/second" do |file|
        file.write "rua"
      end
    end

    assert_equal "00000000004\0", io.string[124, 12]
    assert_equal "tahi", io.string[512, 4]

    assert_equal "00000000003\0", io.string[1148, 12]
    assert_equal "rua", io.string[1536, 3]
  end

  private

  def new_io
    StringIO.new("".b)
  end
end
