# frozen_string_literal: true

require "tar/file_reader"
require "tar/header"
require "tar/header_reader"

module Tar
  class Reader
    include Enumerable

    def initialize(io)
      @io = io
      @header_reader = HeaderReader.new(@io)
    end

    def each
      return to_enum unless block_given?

      loop do
        header = @header_reader.read
        break if header.nil?

        file_reader = FileReader.new(header, @io)
        yield file_reader
        file_reader.skip_to_next_record
      end
    end
  end
end
