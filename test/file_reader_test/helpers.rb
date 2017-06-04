# frozen_string_literal: true

module FileReaderTest
  module Helpers
    FakeHeader = Struct.new(:size)

    def header(size:)
      FakeHeader.new(size)
    end

    def any_header
      header(size: 3)
    end

    def any_io
      io_containing("...")
    end

    def file_containing(contents, **options)
      Tar::FileReader.new(header(size: contents.bytesize), io_containing(contents), **options)
    end

    def new_file
      file_containing("...")
    end

    def closed_file
      new_file.tap(&:close)
    end

    def file_at_eof
      new_file.tap(&:read)
    end

    def binary(string)
      string.dup.force_encoding("binary")
    end

    def iso_8859_13(string)
      string.dup.force_encoding("ISO-8859-13")
    end

    def with_input_record_separator(input_record_separator)
      previous_input_record_separator = $INPUT_RECORD_SEPARATOR
      $INPUT_RECORD_SEPARATOR = input_record_separator
      yield
    ensure
      $INPUT_RECORD_SEPARATOR = previous_input_record_separator
    end

    def with_default_encoding(external: Encoding::UTF_8, internal: nil)
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
  end
end
