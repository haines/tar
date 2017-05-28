# frozen_string_literal: true

require_relative "../test_helper"
require_relative "common_tests"
require_relative "read_to_buffer_tests"
require_relative "seek_tests"
require "tar/backports"

module FileReaderTest
  class StringIOTest < Minitest::Test
    include CommonTests
    include ReadToBufferTests
    include SeekTests

    using Tar::Backports

    private

    def io_containing(contents)
      StringIO.new(+"______#{contents}______").tap { |io| io.pos = 6 }
    end
  end
end
