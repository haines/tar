# frozen_string_literal: true

require "tar/ustar"

module Tar
  class FileWriter
    attr_reader :header

    def initialize(header, io)
      @header = header
      @io = io
    end

    def close
      @io.write("\0" * USTAR.records_padding(header.size))
    end

    def write(data)
      @io.write(data)
    end
  end
end
