# frozen_string_literal: true

require_relative "test_helper"
require "tar/header"

class HeaderTest < Minitest::Test
  def test_parse
    data = "path/to/file".ljust(100, "\0") +   # name
           "000644 \0" +                       # mode
           "000123 \0" +                       # uid
           "000456 \0" +                       # gid
           "00000002070 " +                    # size
           "13105143071 " +                    # mtime
           "013305\0 " +                       # checksum
           "0" +                               # typeflag
           "path/to/link".ljust(100, "\0") +   # link_name
           "ustar\0" +                         # magic
           "00" +                              # version
           "haines".ljust(32, "\0") +          # uname
           "staff".ljust(32, "\0") +           # gname
           "000000 \0" +                       # dev_major
           "000000 \0" +                       # dev_minor
           "prefix/to/add".ljust(155, "\0") +  # prefix
           "\0" * 12                           # padding

    header = Tar::Header.parse(data)

    assert_equal "path/to/file", header.name
    assert_equal 420, header.mode
    assert_equal 83, header.uid
    assert_equal 302, header.gid
    assert_equal 1080, header.size
    assert_equal Time.utc(2017, 5, 11, 20, 14, 49), header.mtime
    assert_equal 5829, header.checksum
    assert_equal "0", header.typeflag
    assert_equal "path/to/link", header.link_name
    assert_equal "ustar", header.magic
    assert_equal "00", header.version
    assert_equal "haines", header.uname
    assert_equal "staff", header.gname
    assert_equal 0, header.dev_major
    assert_equal 0, header.dev_minor
    assert_equal "prefix/to/add", header.prefix
  end

  def test_path_with_prefix
    header = Tar::Header.new(prefix: "path/to", name: "file")

    assert_equal "path/to/file", header.path
  end

  def test_path_without_prefix
    header = Tar::Header.new(prefix: nil, name: "file")

    assert_equal "file", header.path
  end
end
