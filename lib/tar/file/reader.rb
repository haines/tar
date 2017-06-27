# frozen_string_literal: true

require "char_size"
require "tar/file/base"
require "tar/file/line"
require "tar/polyfills"
require "tar/ustar"

module Tar
  module File
    class Reader < Base
      include Enumerable
      using Polyfills

      attr_reader :header

      def initialize(io:, header:, **encoding_options)
        super(io: io, size: header.size, **encoding_options)
        @header = header
        @lineno = 0
      end

      def eof?
        check_not_closed!
        @pos >= @header.size
      end
      alias eof eof?

      def pending
        check_not_closed!
        [0, @header.size - @pos].max
      end

      def lineno
        check_not_closed!
        @lineno
      end

      def lineno=(new_lineno)
        check_not_closed!
        @lineno = new_lineno
      end

      def read(length = nil, buffer = nil)
        check_not_closed!

        data = @io.read(truncate(length), buffer)
        @pos += data.bytesize

        if length.nil?
          encode(data)
        else
          data.force_encoding(Encoding::BINARY)
        end
      end

      def readpartial(max_length, buffer = nil)
        check_not_closed!

        data = @io.readpartial(truncate(max_length), *[buffer].compact)
        @pos += data.bytesize
        data.force_encoding(Encoding::BINARY)
      end

      def skip_to_next_record
        check_not_closed!

        target_pos = USTAR.records_size(@header.size)

        if seekable?
          seek target_pos
        else
          @io.read(target_pos - @pos)
          @pos = target_pos
        end
      end

      def rewind
        super
        @lineno = 0
      end

      def getbyte
        check_not_closed!
        return nil if eof?

        @pos += 1
        @io.getbyte
      end

      def ungetbyte(byte)
        check_not_closed!
        @pos -= 1
        @io.ungetbyte byte
      end

      def readbyte
        check_not_closed!
        check_not_eof!
        getbyte
      end

      def each_byte
        check_not_closed!
        return to_enum(__method__) unless block_given?

        yield getbyte until eof?
      end

      def bytes(&block)
        warn "warning: #{self.class}#bytes is deprecated; use #each_byte instead"
        each_byte(&block)
      end

      def getc
        check_not_closed!
        return nil if eof?

        char = String.new(encoding: Encoding::BINARY)
        min_char_size, max_char_size = CharSize.minmax(external_encoding)

        until char.size == max_char_size || eof?
          char << read(min_char_size)

          char.force_encoding external_encoding
          return encode(char) if char.valid_encoding?

          char.force_encoding Encoding::BINARY
        end

        undo_getc_attempt char, min_char_size

        encode(char)
      end

      def ungetc(char)
        char.encode(external_encoding).bytes.reverse_each do |byte|
          ungetbyte byte
        end
      end

      def readchar
        check_not_closed!
        check_not_eof!
        getc
      end

      def each_char
        check_not_closed!
        return to_enum(__method__) unless block_given?

        yield getc until eof?
      end

      def chars(&block)
        warn "warning: #{self.class}#chars is deprecated; use #each_char instead"
        each_char(&block)
      end

      def each_codepoint
        check_not_closed!
        return to_enum(__method__) unless block_given?

        each_char do |char|
          char.each_codepoint do |codepoint|
            yield codepoint
          end
        end
      end

      def codepoints(&block)
        warn "warning: #{self.class}#codepoints is deprecated; use #each_codepoint instead"
        each_codepoint(&block)
      end

      def gets(*args)
        line = Line.new(self, *args)
        check_not_closed!
        return nil if eof?

        line.read
      end

      def readline(*args)
        line = Line.new(self, *args)
        check_not_closed!
        check_not_eof!
        line.read
      end

      def each_line(*args)
        line = Line.new(self, *args)
        check_not_closed!
        return to_enum(__method__, *args) unless block_given?

        yield line.read until eof?
      end
      alias each each_line

      def lines(*args, &block)
        warn "warning: #{self.class}#lines is deprecated; use #each_line instead"
        each_line(*args, &block)
      end

      def readlines(*args)
        each_line(*args).to_a
      end

      protected

      def extract_encodings(*)
        external_encoding, internal_encoding = super
        external_encoding = parse_bom || external_encoding[4..-1] if parse_bom?(external_encoding)
        [external_encoding, internal_encoding]
      end

      private

      def check_not_eof!
        raise EOFError, "end of file reached" if eof?
      end

      def truncate(length)
        [pending, length].compact.min
      end

      def encode(data)
        data.force_encoding @external_encoding
        data.encode! @internal_encoding, @encoding_options if @internal_encoding
        data
      end

      def undo_getc_attempt(char, min_char_size)
        char.slice!(min_char_size..-1).bytes.reverse_each do |byte|
          ungetbyte byte
        end
      end

      def parse_bom?(encoding)
        encoding.is_a?(String) && /^BOM\|/i.match?(encoding)
      end

      def parse_bom
        return nil unless pos.zero?

        walk_bom_tree(BOM_TREE)
      end

      def walk_bom_tree((tree, encoding))
        byte = getbyte
        found_encoding = walk_bom_tree(tree[byte]) if tree.key?(byte)
        ungetbyte byte unless found_encoding
        found_encoding || encoding
      end

      BOM_TREE = {
        0x00 => { 0x00 => { 0xFE => { 0xFF => [{}, Encoding::UTF_32BE] } } },
        0xEF => { 0xBB => { 0xBF => [{}, Encoding::UTF_8] } },
        0xFE => { 0xFF => [{}, Encoding::UTF_16BE] },
        0xFF => { 0xFE => [{ 0x00 => { 0x00 => [{}, Encoding::UTF_32LE] } }, Encoding::UTF_16LE] }
      }.freeze
      private_constant :BOM_TREE
    end
  end
end
