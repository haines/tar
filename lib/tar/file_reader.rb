# frozen_string_literal: true

require "tar/ustar"

module Tar
  class FileReader
    attr_reader :header, :external_encoding, :internal_encoding, :pos
    alias tell pos

    def initialize(header, io, external_encoding: Encoding.default_external, internal_encoding: Encoding.default_internal, **encoding_options)
      @header = header
      @io = io
      @pos = 0
      set_encoding external_encoding, internal_encoding, **encoding_options
    end

    def eof?
      @pos >= @header.size
    end
    alias eof eof?

    def pending
      [0, @header.size - @pos].max
    end

    def read(length = nil)
      data = @io.read(truncate(length))
      @pos += data.bytesize
      return data if length
      encode(data)
    end

    def skip_to_next_record
      @io.seek USTAR.records_size(@header.size) - @pos, IO::SEEK_CUR
    end

    def set_encoding(external_encoding, *internal_encoding, **encoding_options)
      # TODO: allow setting encoding from BOM
      external_encoding, internal_encoding = extract_encodings(external_encoding, *internal_encoding)
      @external_encoding = find_encoding(external_encoding, if_nil: Encoding.default_external, if_unsupported: Encoding.default_external)
      @internal_encoding = find_encoding(internal_encoding, if_nil: nil, if_unsupported: Encoding.default_internal)
      @encoding_options = encoding_options
    end

    def binmode
      set_encoding Encoding::BINARY
    end

    def binmode?
      @external_encoding == Encoding::BINARY && @internal_encoding.nil?
    end

    private

    def truncate(length)
      [pending, length].compact.min
    end

    def extract_encodings(external_encoding, *internal_encoding)
      raise ArgumentError, "wrong number of arguments (given #{internal_encoding.size + 1}, expected 1..2)" if internal_encoding.size > 1
      return [external_encoding, *internal_encoding] if external_encoding.nil? || external_encoding.is_a?(Encoding) || !internal_encoding.empty?
      external_encoding.split(":", 2)
    end

    def find_encoding(encoding, if_nil:, if_unsupported:)
      return if_nil if encoding.nil? || encoding == ""
      Encoding.find(encoding)
    rescue ArgumentError
      warn "warning: encoding #{encoding} unsupported, defaulting to #{if_unsupported}"
      if_unsupported
    end

    def encode(data)
      data.force_encoding @external_encoding
      data.encode! @internal_encoding, @encoding_options if @internal_encoding
      data
    end
  end
end
