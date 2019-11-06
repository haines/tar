# frozen_string_literal: true

require_relative "../writer_test"
require "tempfile"

module WriterTest
  test_underlying "File" do
    def new_io
      Tempfile.new("writer_test")
    end

    def read_back
      File.read(@io.path).b
    end
  end
end