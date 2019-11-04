# frozen_string_literal: true

module Tar
  module Backports
    unless Enumerable.public_method_defined?(:sum)
      refine Array do
        def sum(identity = 0)
          reduce(identity) { |acc, value| acc + (block_given? ? yield(value) : value) }
        end
      end
    end

    unless Regexp.public_method_defined?(:match?)
      refine Regexp do
        # https://github.com/marcandre/backports/blob/v3.8.0/lib/backports/2.4.0/regexp/match.rb
        def match?(*args)
          Fiber.new {
            !match(*args).nil?
          }.resume
        end
      end
    end
  end
end
