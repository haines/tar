# frozen_string_literal: true

require "tar/ustar"

module Tar
  class FileReader
    attr_reader :header

    def initialize(header, io)
      @header = header
      @io = io
      @pos = 0
    end

    def read
      data = @io.read(@header.size)
      return nil if data.nil?
      @pos += @header.size
      data
    end

    def skip_to_next_record
      @io.seek USTAR.records_size(@header.size) - @pos, IO::SEEK_CUR
    end
  end
end
