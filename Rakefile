# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList["test/**/*_test.rb"]
  t.warning = true
end

if RUBY_ENGINE == "ruby"
  require "char_size/rake/generator_task"
  CharSize::Rake::GeneratorTask.new
end

task :default => :test
