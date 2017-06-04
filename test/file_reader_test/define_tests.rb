# frozen_string_literal: true

require_relative "helpers"

module FileReaderTest
  def self.define_tests(prefix, unsupported: [], &block)
    tests = Dir.glob(File.expand_path("tests/*.rb", __dir__))
               .map { |path| File.basename(path).chomp(".rb") }
               .reject { |name| name.end_with?("_unsupported") }

    (tests - unsupported).each do |name|
      define_test prefix, name, &block
    end

    unsupported.each do |name|
      define_test prefix, "#{name}_unsupported", &block
    end
  end

  def self.define_test(prefix, name, &block)
    require_relative "tests/#{name}"

    camelized_name = name.split("_").map(&:capitalize).join

    test_class = Class.new(Minitest::Test) do
      include Helpers
      include FileReaderTest.const_get(camelized_name)

      def setup
        @file = new_file
      end

      define_method :io_containing, &block
    end

    const_set "#{prefix}#{camelized_name}Test", test_class
  end
end
