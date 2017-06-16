# frozen_string_literal: true

require "tar/error"

module Tar
  module USTAR
    module_function

    RECORD_SIZE = 512

    EOF = "\0" * RECORD_SIZE * 2

    def read_record(io)
      record = io.read(RECORD_SIZE) || ""

      raise UnexpectedEOF, "unexpected end-of-file: attempted to read #{RECORD_SIZE} bytes from #{io}, got #{record.size}" unless record.size == RECORD_SIZE

      record
    end

    def records(file_size)
      (file_size - 1) / RECORD_SIZE + 1
    end

    def records_size(file_size)
      RECORD_SIZE * records(file_size)
    end

    def records_padding(file_size)
      records_size(file_size) - file_size
    end
  end
end
