# frozen_string_literal: true

require "tar/backports"
require "tar/error"
require "tar/header"
require "tar/ustar"

module Tar
  class HeaderReader
    using Backports

    def initialize(io)
      @io = io
    end

    def read
      record = read_record

      if empty?(record)
        return nil if empty?(read_record)

        raise InvalidArchive, "empty header"
      end

      Header.parse(record)
    end

    private

    def read_record
      USTAR.read_record(@io)
    end

    def empty?(record)
      /\A\0+\z/m.match?(record)
    end
  end
end
