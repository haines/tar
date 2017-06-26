# frozen_string_literal: true

require "tar/error"

module Tar
  module Seekable
    def seekable?
      return @seekable if defined?(@seekable)

      @seekable = @io.respond_to?(:seek) && !pipe?
    end

    def pipe?
      @io.pos
      false
    rescue Errno::EPIPE, Errno::ESPIPE
      true
    end

    def check_seekable!(message = "seek not supported by #{@io}")
      raise SeekNotSupported, message unless seekable?
    end
  end
end
