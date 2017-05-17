# frozen_string_literal: true

require_relative "test_helper"
require "tar/file_reader"

class FileReaderTest < Minitest::Test
  def setup
    @file = Tar::FileReader.new(any_header, any_io)
  end

  def test_read_without_internal_encoding
    file = file_containing("kākāpō", external_encoding: "UTF-8", internal_encoding: nil)

    assert_equal "kākāpō", file.read
  end

  def test_read_with_internal_encoding
    file = file_containing("p\xEEwakawaka", external_encoding: "ISO-8859-13", internal_encoding: "UTF-8")

    assert_equal "pīwakawaka", file.read
  end

  def test_read_with_encoding_options
    file = file_containing("hoiho\r\ntawaki\r\n", external_encoding: "UTF-8", internal_encoding: "UTF-8", universal_newline: true)

    assert_equal "hoiho\ntawaki\n", file.read
  end

  def test_read_changes_pos
    file = file_containing("kererū")

    file.read

    assert_equal 7, file.pos
  end

  def test_read_leaves_file_at_eof
    file = file_containing("whio")

    file.read

    assert file.eof?
  end

  def test_read_at_eof_returns_empty_string
    file = file_containing("kea")

    file.read

    assert_equal "", file.read
  end

  def test_a_new_file_has_default_encodings
    file = with_default_encoding(external: "ISO-8859-1", internal: "Windows-1252") {
      Tar::FileReader.new(any_header, any_io)
    }

    assert_equal Encoding::ISO_8859_1, file.external_encoding
    assert_equal Encoding::WINDOWS_1252, file.internal_encoding
  end

  def test_a_new_file_may_have_specified_encodings
    file = Tar::FileReader.new(any_header, any_io, external_encoding: "ISO-8859-1", internal_encoding: "Windows-1252")

    assert_equal Encoding::ISO_8859_1, file.external_encoding
    assert_equal Encoding::WINDOWS_1252, file.internal_encoding
  end

  def test_external_encoding_may_be_a_string
    @file.set_encoding "ISO-8859-1"

    assert_equal Encoding::ISO_8859_1, @file.external_encoding
  end

  def test_external_encoding_may_be_an_encoding
    @file.set_encoding Encoding::ISO_8859_1

    assert_equal Encoding::ISO_8859_1, @file.external_encoding
  end

  def test_fall_back_to_default_when_external_encoding_is_nil
    with_default_encoding external: "ISO-8859-1", internal: "Windows-1252" do
      @file.set_encoding nil
    end

    assert_equal Encoding::ISO_8859_1, @file.external_encoding
  end

  def test_fall_back_to_default_when_external_encoding_is_empty
    with_default_encoding external: "ISO-8859-1", internal: "Windows-1252" do
      @file.set_encoding ""
    end

    assert_equal Encoding::ISO_8859_1, @file.external_encoding
  end

  def test_fall_back_to_default_and_warn_if_external_encoding_does_not_exist
    _out, err = capture_io {
      with_default_encoding external: "ISO-8859-1", internal: "Windows-1252" do
        @file.set_encoding "WTF-8"
      end
    }

    assert_includes err, "warning: "
    assert_includes err, "WTF-8"
    assert_includes err, "ISO-8859-1"

    assert_equal Encoding::ISO_8859_1, @file.external_encoding
  end

  def test_internal_encoding_may_be_explicitly_set_to_nil
    with_default_encoding external: "ISO-8859-1", internal: "Windows-1252" do
      @file.set_encoding "US-ASCII", nil
    end

    assert_nil @file.internal_encoding
  end

  def test_internal_encoding_may_be_implicitly_set_to_nil
    with_default_encoding external: "ISO-8859-1", internal: "Windows-1252" do
      @file.set_encoding "US-ASCII"
    end

    assert_nil @file.internal_encoding
  end

  def test_internal_encoding_may_be_set_to_nil_with_empty_string
    with_default_encoding external: "ISO-8859-1", internal: "Windows-1252" do
      @file.set_encoding "US-ASCII", ""
    end

    assert_nil @file.internal_encoding
  end

  def test_internal_encoding_may_be_a_string
    @file.set_encoding "ISO-8859-1", "Windows-1252"

    assert_equal Encoding::WINDOWS_1252, @file.internal_encoding
  end

  def test_internal_encoding_may_be_an_encoding
    @file.set_encoding "ISO-8859-1", Encoding::WINDOWS_1252

    assert_equal Encoding::WINDOWS_1252, @file.internal_encoding
  end

  def test_fall_back_to_default_and_warn_if_internal_encoding_does_not_exist
    _out, err = capture_io {
      with_default_encoding external: "ISO-8859-1", internal: "Windows-1252" do
        @file.set_encoding "US-ASCII", "WTF-8"
      end
    }

    assert_includes err, "warning: "
    assert_includes err, "WTF-8"
    assert_includes err, "Windows-1252"

    assert_equal Encoding::WINDOWS_1252, @file.internal_encoding
  end

  def test_external_and_internal_encodings_may_be_given_in_one_string
    @file.set_encoding "ISO-8859-1:Windows-1252"

    assert_equal Encoding::ISO_8859_1, @file.external_encoding
    assert_equal Encoding::WINDOWS_1252, @file.internal_encoding
  end

  def test_binmode
    @file.binmode

    assert_equal Encoding::BINARY, @file.external_encoding
    assert_nil @file.internal_encoding
    assert @file.binmode?
  end

  def test_binmode_when_equivalent_settings_applied_manually
    @file.set_encoding "binary", nil

    assert @file.binmode?
  end

  def test_binmode_even_with_encoding_options
    # no transcoding is performed when internal_encoding is nil, so options are irrelevant
    @file.set_encoding "binary", nil, universal_newline: true

    assert @file.binmode?
  end

  private

  def header(size:)
    FakeHeader.new(size)
  end

  def any_header
    header(size: 3)
  end

  def any_io
    StringIO.new("...")
  end

  def file_containing(contents, **options)
    Tar::FileReader.new(header(size: contents.bytesize), io_containing(contents), **options)
  end

  def io_containing(contents)
    StringIO.new("______#{contents}______").tap { |io| io.pos = 6 }
  end

  def with_default_encoding(external:, internal:)
    previous_external = Encoding.default_external
    previous_internal = Encoding.default_internal

    silence_warnings do
      Encoding.default_external = external
      Encoding.default_internal = internal
    end

    yield
  ensure
    silence_warnings do
      Encoding.default_external = previous_external
      Encoding.default_internal = previous_internal
    end
  end

  def silence_warnings
    previous_verbose = $VERBOSE
    $VERBOSE = false
    yield
  ensure
    $VERBOSE = previous_verbose
  end

  FakeHeader = Struct.new(:size)
end
