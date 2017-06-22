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

    def add(contents: nil, size: nil, **header_values, &block)
      if contents
        raise ArgumentError, "expected only one of contents keyword and block, received both" if block_given?

        block = ->(file) { file.write contents }
        size = contents.bytesize
      elsif !block_given?
        block = ->(*) {}
        size = 0
      end

      check_not_closed!

      start_pos = @io.pos
      write_header size: size, **header_values

      file = FileWriter.new(@io, size: size)
      block.call(file)
      file.close

      return if size

      end_pos = @io.pos
      @io.seek start_pos
      write_header size: file.bytes_written, **header_values
      @io.seek end_pos
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

    def write_header(size:, **header_values)
      if size
        @io.write Header.create(size: size, **header_values)
      else
        @io.write "\0" * USTAR::RECORD_SIZE
      end
    end
  end
end
