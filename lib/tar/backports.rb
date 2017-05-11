# frozen_string_literal: true

module Tar
  module Backports
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
