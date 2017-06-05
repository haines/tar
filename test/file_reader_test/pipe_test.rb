# frozen_string_literal: true

require_relative "../test_helper"
require_relative "define_tests"

module FileReaderTest
  define_tests "Pipe", unsupported: ["seek"] do |contents|
    reader, writer = IO.pipe

    writer.write "______#{contents}______"
    writer.close

    reader.read 6
    reader
  end
end
