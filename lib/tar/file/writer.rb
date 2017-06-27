# frozen_string_literal: true

require "tar/ustar"

module Tar
  module File
    class Writer
      attr_reader :bytes_written

      def initialize(io:, size:)
        @io = io
        @size = size
        @bytes_written = 0
      end

      def close
        @io.write("\0" * USTAR.records_padding(@bytes_written))
      end

      def write(data)
        @bytes_written += @io.write(data)
      end
    end
  end
end
