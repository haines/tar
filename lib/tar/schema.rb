# frozen_string_literal: true

module Tar
  class Schema
    def initialize(&block)
      @fields = {}
      instance_eval(&block)
      @fields.freeze

      @unpack_format = @fields.values.map(&:unpack_format).join.freeze
    end

    def field_names
      @fields.keys
    end

    def parse(record)
      @fields.zip(record.unpack(@unpack_format))
             .map { |(name, type), value| [name, type.parse(value)] }
             .to_h
    end

    def string(name, size)
      @fields[name] = String.new(size)
    end

    def octal_number(name, size)
      @fields[name] = OctalNumber.new(size)
    end

    def timestamp(name, size)
      @fields[name] = Timestamp.new(size)
    end

    class String
      attr_reader :unpack_format

      def initialize(size)
        @unpack_format = "Z#{size}"
      end

      def parse(value)
        value unless value.empty?
      end
    end

    class OctalNumber
      attr_reader :size, :unpack_format

      def initialize(size)
        @unpack_format = "A#{size}"
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
