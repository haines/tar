# frozen_string_literal: true

require "char_size"
require "tar/file_reader/line"
require "tar/polyfills"
require "tar/ustar"

module Tar
  class FileReader
    include Enumerable
    using Polyfills

    attr_reader :header

    def initialize(header, io, external_encoding: Encoding.default_external, internal_encoding: Encoding.default_internal, **encoding_options)
      @header = header
      @io = io
      @closed = false
      @lineno = 0
      @pos = 0
      set_encoding external_encoding, internal_encoding, **encoding_options
    end

    def close
      @closed = true
    end

    def closed?
      @closed || @io.closed?
    end

    def eof?
      check_not_closed!
      @pos >= @header.size
    end
    alias eof eof?

    def pos
      check_not_closed!
      @pos
    end
    alias tell pos

    def pos=(new_pos)
      seek new_pos
    end

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

      external_encoding = parse_bom || external_encoding[4..-1] if parse_bom?(external_encoding)

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

    private

    def truncate(length)
      [pending, length].compact.min
    end

    def extract_encodings(external_encoding, *internal_encoding)
      raise ArgumentError, "wrong number of arguments (given #{internal_encoding.size + 1}, expected 1..2)" if internal_encoding.size > 1
      return [external_encoding, *internal_encoding] if external_encoding.nil? || external_encoding.is_a?(Encoding) || !internal_encoding.empty?

      external_encoding.split(":", 2)
    end

    def parse_bom?(encoding)
      encoding.is_a?(String) && /^BOM\|/i.match?(encoding)
    end

    def parse_bom
      return nil unless pos.zero?

      walk_bom_tree(BOM_TREE)
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

    def relativize(amount, mode)
      case mode
      when :CUR, IO::SEEK_CUR then amount
      when :SET, IO::SEEK_SET then amount - @pos
      when :END, IO::SEEK_END then @header.size + amount - @pos
      else raise ArgumentError, "unknown seek mode #{mode.inspect}, expected :CUR, :END, or :SET (or IO::SEEK_*)"
      end
    end

    def undo_getc_attempt(char, min_char_size)
      char.slice!(min_char_size..-1).bytes.reverse_each do |byte|
        ungetbyte byte
      end
    end

    def check_not_closed!
      raise IOError, "closed stream" if closed?
    end

    def check_not_eof!
      raise EOFError, "end of file reached" if eof?
    end

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

    def check_seekable!
      raise SeekNotSupported, "seek not supported by #{@io}" unless seekable?
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
