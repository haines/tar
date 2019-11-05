# frozen_string_literal: true

require_relative "test_helper"
require "tar/ustar"

class USTARTest < Minitest::Test
  def test_read_records
    first = "X" * 512
    second = "Y" * 512
    io = StringIO.new(first + second)

    assert_equal first, Tar::USTAR.read_record(io)
    assert_equal second, Tar::USTAR.read_record(io)
  end

  def test_read_at_eof
    io = StringIO.new

    assert_raises Tar::UnexpectedEOF do
      Tar::USTAR.read_record(io)
    end
  end

  def test_read_near_eof
    io = StringIO.new("X" * 256)

    assert_raises Tar::UnexpectedEOF do
      Tar::USTAR.read_record(io)
    end
  end

  def test_records
    {
      0 => 0,
      1 => 1,
      512 => 1,
      513 => 2,
      1024 => 2,
      9000 => 18
    }.each do |file_size, records|
      assert_equal records, Tar::USTAR.records(file_size), "Wrong number of records for a file size of #{file_size}"
    end
  end

  def test_records_size
    {
      0 => 0,
      1 => 512,
      512 => 512,
      513 => 1024,
      1024 => 1024,
      9000 => 9216
    }.each do |file_size, records_size|
      assert_equal records_size, Tar::USTAR.records_size(file_size), "Wrong records size for a file size of #{file_size}"
    end
  end
end
