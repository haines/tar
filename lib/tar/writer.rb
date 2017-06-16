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

    def add(path:, size:)
      header = Header.create(path: path, size: size)
      @io.write header

      writer = FileWriter.new(header, @io)
      yield writer
      writer.close
    end
  end
end
