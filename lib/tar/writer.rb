# frozen_string_literal: true

require "tar/file_writer"
require "tar/header"
require "tar/ustar"

module Tar
  class Writer
    def initialize(io)
      @io = io
    end

    def close
      @io.write USTAR::EOF
    end

    def add(**header_values)
      header = Header.create(**header_values)
      @io.write header

      writer = FileWriter.new(@io, size: header.size)
      yield writer
      writer.close
    end
  end
end
