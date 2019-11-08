# frozen_string_literal: true

require_relative "define_tests"
require_relative "test_helper"
require "tar/file/reader"

module FileReaderTest
  extend DefineTests

  def self.test_underlying(*args, &block)
    define_tests "file_reader_test", *args do
      def setup
        @file = new_file
      end

      class_eval(&block)

      private

      def header(size:)
        Struct.new(:size).new(size)
      end

      def any_header
        header(size: 3)
      end

      def any_io
        io_containing("...")
      end

      def file_containing(contents, **options)
        Tar::File::Reader.new(io: io_containing(contents), header: header(size: contents.bytesize), **options)
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

      def iso_8859_13(string)
        string.dup.force_encoding("ISO-8859-13")
      end

      def us_ascii(string)
        string.dup.force_encoding("US-ASCII")
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
end
