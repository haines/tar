# frozen_string_literal: true

require_relative "define_tests"
require_relative "test_helper"
require "tar/file/writer"

module FileWriterTest
  extend DefineTests

  def self.test_underlying(*args, &block)
    define_tests "file_writer_test", *args do
      def teardown
        @io.close unless @io.closed?
      end

      class_eval(&block)

      private

      def new_file(**options)
        Tar::File::Writer.new(io: @io, **options)
      end

      def closed_file
        new_file.tap(&:close)
      end

      def written
        @io.close unless @io.closed?
        @written ||= read_back
      end
    end
  end
end
