# frozen_string_literal: true

require "tar/error"

module Tar
  class Checksum
    def initialize(record)
      @record = record
      @value = Header.clear_checksum(record).chars.sum(&:ord)
    end

    def check!(expected)
      raise ChecksumMismatch.for(@record, expected: expected, actual: @value) unless @value == expected
    end
  end
end
