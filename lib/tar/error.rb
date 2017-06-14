# frozen_string_literal: true

module Tar
  Error = Class.new(StandardError)

  InvalidArchive = Class.new(Error)

  class ChecksumMismatch < InvalidArchive
    def self.for(record, expected:, actual:)
      new("checksum mismatch: expected #{expected}, got #{actual} for record #{record.inspect}")
    end
  end

  UnexpectedEOF = Class.new(InvalidArchive)

  SeekNotSupported = Class.new(Error)
end
