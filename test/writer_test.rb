# frozen_string_literal: true

require_relative "define_tests"
require_relative "test_helper"
require "tar/writer"

module WriterTest
  extend DefineTests

  def self.test_underlying(*args, &block)
    define_tests "writer_test", *args, &block
  end
end
