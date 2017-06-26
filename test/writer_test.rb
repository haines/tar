# frozen_string_literal: true

require_relative "define_tests"
require_relative "test_helper"
require "tar/writer"

module WriterTest
  extend DefineTests

  def self.test_underlying(*args, &block)
    define_tests "writer_test", *args do
      def setup
        @io = new_io
      end

      def teardown
        @io.close unless @io.closed?
      end

      class_eval(&block)

      private

      def written
        @io.close unless @io.closed?
        @written ||= read_back
      end
    end
  end
end
