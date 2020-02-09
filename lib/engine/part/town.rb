# frozen_string_literal: true

require 'engine/part/base'

module Engine
  module Part
    class Town < Base
      attr_reader :id, :revenue

      def initialize(revenue, id = 0)
        @id = id.to_i
        @revenue = revenue.to_i
      end

      def ==(other)
        other.town? && (@revenue == other.revenue) && (@id == other.id)
      end

      def <=(other)
        other.town? && (@id == other.id)
      end

      def town?
        true
      end
    end
  end
end
