# frozen_string_literal: true

require "tar/ustar"

module Tar
  class FileWriter
    attr_reader :header

    def initialize(io, size:)
      @io = io
      @size = size
    end

    def close
      @io.write("\0" * USTAR.records_padding(@size))
    end

    def write(data)
      @io.write(data)
    end
  end
end
