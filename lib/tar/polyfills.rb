# frozen_string_literal: true

require "zlib"

module Tar
  module Polyfills
    refine Zlib::GzipReader do
      def read(length = nil, buffer = nil)
        raise ArgumentError, "#{self.class} does not support read to buffer" unless buffer.nil?

        super(length)
      end
    end
  end
end
