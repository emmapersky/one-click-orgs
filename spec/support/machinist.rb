module Machinist
  module ActiveRecordExtensions
    module ClassMethods
      def make_n(n, attributes={})
        Array.new(n) { make(attributes) }
      end
    end
  end
end
