# frozen_string_literal: true

require "tar/error"
require "tar/ustar"

module Tar
  class Header
    attr_reader :path, :size

    def initialize(path:, size:)
      @path = path
      @size = size
    end

    def self.parse(record)
      path, size = record.unpack("Z100 x24 A12")
      new(path: path, size: size.oct)
    end
  end
end
