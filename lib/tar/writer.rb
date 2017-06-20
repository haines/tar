# frozen_string_literal: true

require "tar/file_writer"
require "tar/header"
require "tar/ustar"

module Tar
  class Writer
    def initialize(io, &block)
      @io = io
      @closed = false
      yield_self_and_close(&block) if block_given?
    end

    def close
      @io.write USTAR::EOF
      @closed = true
    end

    def closed?
      @closed || @io.closed?
    end

    def add(**header_values)
      check_not_closed!

      header = Header.create(**header_values)
      @io.write header

      writer = FileWriter.new(@io, size: header.size)
      yield writer if block_given?
      writer.close
    end

    private

    def check_not_closed!
      raise IOError, "closed stream" if closed?
    end

    def yield_self_and_close
      yield self
    ensure
      close
    end
  end
end
