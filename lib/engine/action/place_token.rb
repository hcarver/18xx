# frozen_string_literal: true

require 'engine/action/base'

module Engine
  module Action
    class PlaceToken < Base
      attr_reader :city, :slot

      def initialize(entity, city, slot)
        @entity = entity
        @city = city
        @slot = slot
      end

      def self.h_to_args(h, game)
        [game.city_by_id(h['city']), h['slot']]
      end

      def args_to_h
        {
          'city' => @city.id,
          'slot' => @slot,
        }
      end
    end
  end
end
