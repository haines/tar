# frozen_string_literal: true

require_relative "test_helper"
require "tar/header"

class HeaderTest < Minitest::Test
  def test_create_with_minimal_data
    header = Timecop.freeze(Time.utc(1999, 12, 31, 23, 59, 59)) {
      Tar::Header.create(path: "path/to/file", size: 42)
    }

    assert_equal "path/to/file", header.name
    assert_equal 0o644, header.mode
    assert_equal 0, header.uid
    assert_equal 0, header.gid
    assert_equal 42, header.size
    assert_equal Time.utc(1999, 12, 31, 23, 59, 59), header.mtime
    assert_equal 4249, header.checksum
    assert_equal "0", header.type_flag
    assert_nil header.link_name
    assert_equal "ustar", header.magic
    assert_equal "00", header.version
    assert_nil header.uname
    assert_nil header.gname
    assert_nil header.dev_major
    assert_nil header.dev_minor
    assert_nil header.prefix
    assert_equal "path/to/file", header.path
  end

  def test_create_splits_long_path
    path = "#{'aa/aa' * 31}/#{'bb/bb' * 20}"
    header = Tar::Header.create(path: path, size: 42)

    assert_equal "bb/bb" * 20, header.name
    assert_equal "aa/aa" * 31, header.prefix
    assert_equal path, header.path
  end

  def test_path_length_too_long
    assert_raises ArgumentError do
      Tar::Header.create(path: "#{'aa/aa' * 31}/#{'bb/bb' * 20}c", size: 42)
    end
  end

  def test_path_not_splittable
    assert_raises ArgumentError do
      Tar::Header.create(path: "a/#{'b' * 154}/c", size: 42)
    end
  end

  def test_create_with_maximal_data
    header = Tar::Header.create(
      path: "#{'a' * 50}/#{'b' * 50}",
      size: 42,
      mode: 0o755,
      uid: 123,
      uname: "haines",
      gid: 456,
      gname: "staff",
      mtime: Time.utc(2000, 1, 1, 0, 0, 0),
      type_flag: "1",
      link_name: "c" * 50,
      dev_major: 9000,
      dev_minor: 99
    )

    assert_equal "b" * 50, header.name
    assert_equal 0o755, header.mode
    assert_equal 123, header.uid
    assert_equal 456, header.gid
    assert_equal 42, header.size
    assert_equal Time.utc(2000, 1, 1, 0, 0, 0), header.mtime
    assert_equal 19_649, header.checksum
    assert_equal "1", header.type_flag
    assert_equal "c" * 50, header.link_name
    assert_equal "ustar", header.magic
    assert_equal "00", header.version
    assert_equal "haines", header.uname
    assert_equal "staff", header.gname
    assert_equal 9000, header.dev_major
    assert_equal 99, header.dev_minor
    assert_equal "a" * 50, header.prefix
    assert_equal "#{'a' * 50}/#{'b' * 50}", header.path
  end

  def test_path_is_required
    assert_raises ArgumentError do
      Tar::Header.create(size: 42)
    end
  end

  def test_path_may_not_be_nil
    assert_raises ArgumentError do
      Tar::Header.create(path: nil, size: 42)
    end
  end

  def test_size_is_required
    assert_raises ArgumentError do
      Tar::Header.create(path: "path/to/file")
    end
  end

  def test_size_may_not_be_nil
    assert_raises ArgumentError do
      Tar::Header.create(path: "path/to/file", size: nil)
    end
  end

  def test_strings_must_be_ascii_compatible
    assert_raises ArgumentError do
      Tar::Header.create(path: "path/to/file", size: 42, uname: "tarāpuka")
    end
  end

  def test_empty_strings_are_coerced_to_nil
    header = Tar::Header.create(path: "path/to/file", size: 42, gname: "")

    assert_nil header.gname
  end

  def test_fixed_width_strings_must_not_be_longer_than_field_size
    assert_raises ArgumentError do
      Tar::Header.create(path: "path/to/file", size: 42, link_name: "x" * 101)
    end
  end

  def test_fixed_width_strings_may_fill_field
    header = Tar::Header.create(path: "path/to/file", size: 42, link_name: "x" * 100)

    assert_equal "x" * 100, header.link_name
  end

  def test_null_terminated_strings_are_truncated_to_fit
    header = Tar::Header.create(path: "path/to/file", size: 42, uname: "x" * 100)

    assert_equal "x" * 31, header.uname
  end

  def test_octal_fields_must_not_be_negative
    assert_raises ArgumentError do
      Tar::Header.create(path: "path/to/file", size: 42, dev_major: -1)
    end
  end

  def test_octal_fields_must_not_overflow
    assert_raises ArgumentError do
      Tar::Header.create(path: "path/to/file", size: 42, dev_minor: 0o10000000)
    end
  end

  def test_timestamps_must_not_be_negative
    assert_raises ArgumentError do
      Tar::Header.create(path: "path/to/file", size: 42, mtime: Time.utc(1969, 12, 31, 23, 59, 59))
    end
  end

  def test_timestamps_may_be_zero
    header = Tar::Header.create(path: "path/to/file", size: 42, mtime: Time.utc(1970, 1, 1, 0, 0, 0))

    assert_equal Time.utc(1970, 1, 1, 0, 0, 0), header.mtime
  end

  def test_timestamps_have_fractional_seconds_truncated
    header = Tar::Header.create(path: "path/to/file", size: 42, mtime: Time.utc(2017, 6, 17, 15, 40, 26.473))

    assert_equal Time.utc(2017, 6, 17, 15, 40, 26), header.mtime
  end

  def test_parse
    header = Tar::Header.parse(header_data("020523"))

    assert_equal "path/to/file", header.name
    assert_equal 0o644, header.mode
    assert_equal 83, header.uid
    assert_equal 302, header.gid
    assert_equal 1080, header.size
    assert_equal Time.utc(2017, 5, 11, 20, 14, 49), header.mtime
    assert_equal 0o20523, header.checksum
    assert_equal "0", header.type_flag
    assert_equal "path/to/link", header.link_name
    assert_equal "ustar", header.magic
    assert_equal "00", header.version
    assert_equal "haines", header.uname
    assert_equal "staff", header.gname
    assert_equal 0, header.dev_major
    assert_equal 0, header.dev_minor
    assert_equal "prefix/to/add", header.prefix
    assert_equal "prefix/to/add/path/to/file", header.path
  end

  def test_parse_fails_if_checksum_is_invalid
    assert_raises Tar::ChecksumMismatch do
      Tar::Header.parse(header_data("012345"))
    end
  end

  private

  def header_data(checksum)
    "path/to/file".ljust(100, "\0") +     # name
      "000644 \0" +                       # mode
      "000123 \0" +                       # uid
      "000456 \0" +                       # gid
      "00000002070 " +                    # size
      "13105143071 " +                    # mtime
      "#{checksum}\0 " +                  # checksum
      "0" +                               # type_flag
      "path/to/link".ljust(100, "\0") +   # link_name
      "ustar\0" +                         # magic
      "00" +                              # version
      "haines".ljust(32, "\0") +          # uname
      "staff".ljust(32, "\0") +           # gname
      "000000 \0" +                       # dev_major
      "000000 \0" +                       # dev_minor
      "prefix/to/add".ljust(155, "\0") +  # prefix
      "\0" * 12                           # padding
  end
end
