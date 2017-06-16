# frozen_string_literal: true

require "tar/ustar"

module Tar
  class Schema
    attr_reader :field_names

    def initialize(**definition)
      @fields, = definition.reduce([{}, 0]) { |(fields, offset), (name, (type, size))|
        [{ **fields, name => type.new(offset: offset, size: size) }, offset + size]
      }

      @field_names = @fields.keys
      field_types = @fields.values

      @pack_format = field_types.map(&:pack_format).join
      @unpack_format = field_types.map(&:unpack_format).join
    end

    def field_size(field_name)
      @fields.fetch(field_name).size
    end

    def clear(record, field_name)
      type = @fields.fetch(field_name)

      record.dup.tap { |new_record| new_record[type.offset, type.size] = " " * type.size }
    end

    def coerce(values)
      @fields.zip(values.fetch_values(*@field_names))
             .map { |(name, type), value| [name, type.coerce(value)] }
             .to_h
    end

    def format(values)
      @fields.zip(values.fetch_values(*@field_names))
             .map { |(_, type), value| type.format(value) }
             .pack(@pack_format)
             .ljust(USTAR::RECORD_SIZE, "\0")
    end

    def parse(record)
      @fields.zip(record.unpack(@unpack_format))
             .map { |(name, type), value| [name, type.parse(value)] }
             .to_h
    end

    module FieldTypes
      def fixed_width_string(size)
        [FixedWidthString, size]
      end

      def null_terminated_string(size)
        [NullTerminatedString, size]
      end

      def octal_number(size)
        [OctalNumber, size]
      end

      def timestamp(size)
        [Timestamp, size]
      end

      class Base
        attr_reader :offset, :size, :pack_format, :unpack_format

        def initialize(offset:, size:, pack_format:, unpack_format:)
          @offset = offset
          @size = size
          @pack_format = pack_format
          @unpack_format = unpack_format
        end
      end

      class StringBase < Base
        def initialize(size:, **args)
          super(**args, size: size, unpack_format: "Z#{size}")
        end

        def coerce(value)
          value.to_s unless value.nil? || value.to_s.empty?
        end

        def format(value)
          value.to_s
        end

        def parse(value)
          value unless value.empty?
        end
      end

      class FixedWidthString < StringBase
        def initialize(size:, **args)
          super(**args, size: size, pack_format: "a#{size}")
        end
      end

      class NullTerminatedString < StringBase
        def initialize(size:, **args)
          super(**args, size: size, pack_format: "a#{size - 1}x")
        end
      end

      class OctalNumber < Base
        def initialize(size:, **args)
          super(**args, size: size, pack_format: "a#{size}", unpack_format: "A#{size}")
        end

        def coerce(value)
          Integer(value) unless value.nil?
        end

        def format(value)
          return "" if value.nil?

          Kernel.format("%0#{size - 1}o", value)
        end

        def parse(value)
          value.oct
        end
      end

      class Timestamp < OctalNumber
        def coerce(value)
          Time.at(value) unless value.nil?
        end

        def parse(value)
          Time.at(super)
        end
      end
    end
  end
end
