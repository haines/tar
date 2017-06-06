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

    unless Numeric.public_method_defined?(:negative?)
      refine Numeric do
        def negative?
          self < 0
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

    unless String.public_method_defined?(:+@)
      refine String do
        # https://github.com/marcandre/backports/blob/v3.8.0/lib/backports/2.3.0/string/uplus.rb
        def +@
          frozen? ? dup : self
        end
      end
    end

    begin
      String.new(encoding: Encoding::BINARY)
    rescue TypeError
      refine String.singleton_class do
        def new(string = "", encoding: nil)
          super(string).force_encoding(encoding)
        end
      end
    end
  end
end
