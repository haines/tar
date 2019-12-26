# frozen_string_literal: true

module DefineTests
  def define_tests(directory, prefix, unsupported: [], &block)
    tests = Dir.glob(File.expand_path("#{directory}/tests/*.rb", __dir__))
               .map { |path| File.basename(path).chomp(".rb") }
               .reject { |name| name.end_with?("_unsupported") }

    (tests - unsupported).each do |name|
      define_test directory, prefix, name, &block
    end

    unsupported.each do |name|
      define_test directory, prefix, "#{name}_unsupported", &block
    end
  end

  def define_test(directory, prefix, name, &block)
    require_relative "#{directory}/tests/#{name}"

    camelized_name = name.split("_").map(&:capitalize).join
    tests_module = const_get(camelized_name)

    test_class = Class.new(Minitest::Test) do
      include tests_module
      class_eval(&block)
    end

    const_set "#{prefix}#{camelized_name}Test", test_class
  end
end
