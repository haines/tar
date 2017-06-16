# frozen_string_literal: true

require "tar/checksum"
require "tar/schema"
require "tar/ustar"

module Tar
  class Header
    extend Schema::FieldTypes
    private_class_method(*Schema::FieldTypes.instance_methods)

    SCHEMA = Schema.new(
      name: fixed_width_string(100),
      mode: octal_number(8),
      uid: octal_number(8),
      gid: octal_number(8),
      size: octal_number(12),
      mtime: timestamp(12),
      checksum: octal_number(8),
      type_flag: fixed_width_string(1),
      link_name: fixed_width_string(100),
      magic: null_terminated_string(6),
      version: fixed_width_string(2),
      uname: null_terminated_string(32),
      gname: null_terminated_string(32),
      dev_major: octal_number(8),
      dev_minor: octal_number(8),
      prefix: fixed_width_string(155)
    )

    def initialize(values)
      @values = values
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

    def to_s
      SCHEMA.format(@values)
    end

    def self.create(
      path:,
      size:,
      mode: 0o644,
      uid: 0,
      uname: nil,
      gid: 0,
      gname: nil,
      mtime: Time.now,
      type_flag: "0",
      link_name: nil,
      dev_major: nil,
      dev_minor: nil
    )
      prefix, name = split_path(path)

      values = Header::SCHEMA.coerce(
        name: name,
        mode: mode,
        uid: uid,
        gid: gid,
        size: size,
        mtime: mtime,
        checksum: nil,
        type_flag: type_flag,
        link_name: link_name,
        magic: "ustar",
        version: "00",
        uname: uname,
        gname: gname,
        dev_major: dev_major,
        dev_minor: dev_minor,
        prefix: prefix
      )

      new(**values, checksum: Checksum.new(SCHEMA.format(values)).to_i)
    end

    def self.parse(record)
      values = SCHEMA.parse(record)
      Checksum.new(record).check!(values.fetch(:checksum))
      new(values)
    end

    def self.clear_checksum(record)
      SCHEMA.clear(record, :checksum)
    end

    def self.split_path(path)
      return [nil, path] if path.length <= SCHEMA.field_size(:name)

      split_at = path.index("/", -SCHEMA.field_size(:name) - 1)
      raise ArgumentError, "file path too long" if split_at.nil? || split_at > SCHEMA.field_size(:prefix)

      [path[0, split_at], path[(split_at + 1)..-1]]
    end
    private_class_method :split_path

    private_class_method :new
  end
end
