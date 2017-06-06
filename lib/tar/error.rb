# frozen_string_literal: true

module Tar
  Error = Class.new(StandardError)

  InvalidArchive = Class.new(Error)
  ChecksumMismatch = Class.new(InvalidArchive)
  UnexpectedEOF = Class.new(InvalidArchive)

  SeekNotSupported = Class.new(Error)
end
