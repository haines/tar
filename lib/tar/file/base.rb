# frozen_string_literal: true

require "tar/seekable"

module Tar
  module File
    class Base
      include Seekable

      def initialize(io:, size:, external_encoding: Encoding.default_external, internal_encoding: Encoding.default_internal, **encoding_options)
        @io = io
        @size = size
        @closed = false
        @pos = 0
        set_encoding external_encoding, internal_encoding, **encoding_options
      end

      def close
        @closed = true
      end

      def closed?
        @closed || @io.closed?
      end

      def pos
        check_not_closed!
        @pos
      end
      alias tell pos

      def pos=(new_pos)
        seek new_pos
      end

      def external_encoding
        check_not_closed!
        @external_encoding
      end

      def internal_encoding
        check_not_closed!
        @internal_encoding
      end

      def set_encoding(external_encoding, *internal_encoding, **encoding_options)
        check_not_closed!

        external_encoding, internal_encoding = extract_encodings(external_encoding, *internal_encoding)

        @external_encoding = find_encoding(external_encoding, if_nil: Encoding.default_external, if_unsupported: Encoding.default_external)
        @internal_encoding = find_encoding(internal_encoding, if_nil: nil, if_unsupported: Encoding.default_internal)
        @encoding_options = encoding_options
      end

      def binmode
        set_encoding Encoding::BINARY
      end

      def binmode?
        check_not_closed!
        @external_encoding == Encoding::BINARY && @internal_encoding.nil?
      end

      def tty?
        check_not_closed!
        @io.respond_to?(:tty?) && @io.tty?
      end
      alias isatty tty?

      def seek(amount, mode = IO::SEEK_SET)
        check_seekable!
        check_not_closed!
        offset = relativize(amount, mode)
        @io.seek offset, IO::SEEK_CUR
        @pos += offset
      end

      def rewind
        seek 0
        @lineno = 0
      end

      protected

      def check_not_closed!
        raise IOError, "closed stream" if closed?
      end

      def extract_encodings(external_encoding, *internal_encoding)
        raise ArgumentError, "wrong number of arguments (given #{internal_encoding.size + 1}, expected 1..2)" if internal_encoding.size > 1
        return [external_encoding, *internal_encoding] if external_encoding.nil? || external_encoding.is_a?(Encoding) || !internal_encoding.empty?

        external_encoding.split(":", 2)
      end

      private

      def relativize(amount, mode)
        case mode
        when :CUR, IO::SEEK_CUR then amount
        when :SET, IO::SEEK_SET then amount - @pos
        when :END, IO::SEEK_END then @size + amount - @pos
        else raise ArgumentError, "unknown seek mode #{mode.inspect}, expected :CUR, :END, or :SET (or IO::SEEK_*)"
        end
      end

      def find_encoding(encoding, if_nil:, if_unsupported:)
        return if_nil if encoding.nil? || encoding == ""

        Encoding.find(encoding)
      rescue ArgumentError
        warn "warning: encoding #{encoding} unsupported, defaulting to #{if_unsupported}"
        if_unsupported
      end
    end
  end
end
