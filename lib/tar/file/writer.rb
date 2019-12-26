# frozen_string_literal: true

require "tar/file/base"
require "tar/ustar"

module Tar
  module File
    class Writer < Base
      def initialize(io:, size: nil)
        super(io: io, size: size)
        @bytes_written = 0
      end

      def size
        super || @bytes_written
      end

      def close
        @io.write("\0" * USTAR.records_padding(@bytes_written))
        super
      end

      def write(data)
        @pos += @io.write(data)
        @bytes_written = @pos if @pos > @bytes_written
      end
    end
  end
end
