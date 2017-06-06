# frozen_string_literal: true

module Tar
  class Schema
    def initialize(&block)
      @fields = {}
      @offset = 0
      instance_eval(&block)
      @fields.freeze

      @unpack_format = @fields.values.map(&:unpack_format).join.freeze
    end

    def field_names
      @fields.keys
    end

    def clear(record, field_name)
      field = @fields.fetch(field_name)

      record.dup.tap { |new_record|
        new_record[field.offset, field.size] = " " * field.size
      }
    end

    def parse(record)
      @fields.zip(record.unpack(@unpack_format))
             .map { |(name, type), value| [name, type.parse(value)] }
             .to_h
    end

    def string(name, size)
      add_field name, String, size
    end

    def octal_number(name, size)
      add_field name, OctalNumber, size
    end

    def timestamp(name, size)
      add_field name, Timestamp, size
    end

    private

    def add_field(name, type, size)
      @fields[name] = type.new(size, @offset)
      @offset += size
    end

    class FieldType
      attr_reader :size, :offset, :unpack_format

      def initialize(size, offset, unpack_format:)
        @size = size
        @offset = offset
        @unpack_format = unpack_format
      end
    end

    class String < FieldType
      def initialize(size, offset)
        super(size, offset, unpack_format: "Z#{size}")
      end

      def parse(value)
        value unless value.empty?
      end
    end

    class OctalNumber < FieldType
      def initialize(size, offset)
        super(size, offset, unpack_format: "A#{size}")
      end

      def parse(value)
        value.oct
      end
    end

    class Timestamp < OctalNumber
      def parse(value)
        Time.at(super)
      end
    end
  end
end
