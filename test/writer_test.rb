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

  private

  def new_io
    StringIO.new("".dup.force_encoding("binary"))
  end
end
