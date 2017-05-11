# frozen_string_literal: true

module Tar
  Error = Class.new(StandardError)
  InvalidArchive = Class.new(Error)
  UnexpectedEOF = Class.new(Error)
end
