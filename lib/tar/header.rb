# frozen_string_literal: true

require "tar/error"
require "tar/schema"
require "tar/ustar"

module Tar
  class Header
    SCHEMA = Schema.new {
      string :name, 100
      octal_number :mode, 8
      octal_number :uid, 8
      octal_number :gid, 8
      octal_number :size, 12
      timestamp :mtime, 12
      octal_number :checksum, 8
      string :typeflag, 1
      string :link_name, 100
      string :magic, 6
      string :version, 2
      string :uname, 32
      string :gname, 32
      octal_number :dev_major, 8
      octal_number :dev_minor, 8
      string :prefix, 155
    }

    def initialize(values, checksum: nil)
      @values = values
      check_checksum!(checksum) if checksum
    end

    SCHEMA.field_names.each do |name|
      define_method name do
        @values.fetch(name)
      end
    end

    def path
      return name if prefix.nil?

      "#{prefix}/#{name}"
    end

    def self.parse(record)
      expected_checksum = SCHEMA.clear(record, :checksum).chars.sum(&:ord)
      new(SCHEMA.parse(record), checksum: expected_checksum)
    end

    private

    def check_checksum!(expected_checksum)
      raise ChecksumMismatch, "checksum mismatch at #{path.inspect}: expected #{expected_checksum}, got #{checksum}" unless checksum == expected_checksum
    end
  end
end
