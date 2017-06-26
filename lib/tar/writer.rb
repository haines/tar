# frozen_string_literal: true

require "tar/file_writer"
require "tar/header"
require "tar/seekable"
require "tar/ustar"

module Tar
  class Writer
    include Seekable

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

      write size: size, **header_values, &block
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

    def write(size:, **header_values, &block)
      check_not_closed!

      if size
        write_with_size(size: size, **header_values, &block)
      else
        write_without_size(**header_values, &block)
      end
    end

    def write_with_size(size:, **header_values, &block)
      write_header(size: size, **header_values)
      write_file(size: size, &block)
    end

    def write_without_size(**header_values, &block)
      check_seekable! message: "can't write header without size (seek not supported by #{@io})"

      start_pos = @io.pos
      write_placeholder
      bytes_written = write_file(&block)
      end_pos = @io.pos
      @io.seek start_pos
      write_header size: bytes_written, **header_values
      @io.seek end_pos
    end

    def write_header(**values)
      @io.write Header.create(**values)
    end

    def write_placeholder
      @io.write "\0" * USTAR::RECORD_SIZE
    end

    def write_file(size: nil)
      file = FileWriter.new(@io, size: size)
      yield file
      file.close
      file.bytes_written
    end
  end
end
