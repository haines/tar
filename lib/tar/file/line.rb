# frozen_string_literal: true

require "English"

module Tar
  module File
    class Line
      def initialize(file, *args)
        @file = file
        @skip = nil

        case args.size
        when 0
          use_default_separator
          use_default_limit
        when 1
          extract_separator_or_limit(*args)
        when 2
          extract_separator(args.first)
          extract_limit(args.last)
        else
          raise ArgumentError, "wrong number of arguments (given #{args.size}, expected 0..2)"
        end
      end

      def read
        return @file.read if read_to_eof?

        skip_newlines if @skip
        line = read_line
        skip_newlines if @skip
        line
      end

      private

      def skip_newlines
        until @file.eof?
          char = @file.getc
          if char != @skip
            @file.ungetc char
            break
          end
        end
      end

      def read_line
        line = String.new(encoding: encoding)
        line << @file.getc until stop_reading?(line)
        @file.lineno += 1 if reached_separator?(line)
        line
      end

      def encoding
        @file.internal_encoding || @file.external_encoding
      end

      def use_default_separator
        @separator = $INPUT_RECORD_SEPARATOR
      end

      def use_default_limit
        @limit = nil
      end

      def extract_separator_or_limit(separator_or_limit)
        if separator_or_limit.respond_to?(:to_int)
          use_default_separator
          extract_limit(separator_or_limit)
        else
          extract_separator(separator_or_limit)
          use_default_limit
        end
      end

      def extract_separator(separator)
        case separator
        when nil
          @separator = nil
        when ""
          @separator = "\n\n".encode(encoding)
          @skip = "\n".encode(encoding)
        else
          @separator = separator.to_str.encode(encoding)
        end
      end

      def extract_limit(limit)
        if limit.nil?
          use_default_limit
        else
          @limit = limit.to_int
          use_default_limit if @limit.negative?
        end
      end

      def read_to_eof?
        @separator.nil? && @limit.nil?
      end

      def stop_reading?(line)
        reached_separator?(line) || reached_limit?(line) || @file.eof?
      end

      def reached_separator?(line)
        @separator && line.end_with?(@separator)
      end

      def reached_limit?(line)
        @limit && line.bytesize >= @limit
      end
    end
  end
end
