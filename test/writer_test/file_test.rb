# frozen_string_literal: true

require_relative "../writer_test"
require "tempfile"

module WriterTest
  test_underlying "File" do
    def setup
      @io = Tempfile.new("writer_test").tap { |file| file.sync = true }
    end

    def written
      File.read(@io.path).b
    end
  end
end
