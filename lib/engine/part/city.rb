# frozen_string_literal: true

require 'engine/part/base'

module Engine
  module Part
    class City < Base
      attr_accessor :reservations, :tile
      attr_reader :id, :revenue, :slots, :tokens

      def initialize(revenue, slots = 1, id = 0, reservations = [])
        @revenue = revenue.to_i
        @slots = slots.to_i
        @id = id.to_i
        @tokens = Array.new(@slots)
        @reservations = reservations&.map(&:to_sym) || []
        @tile = nil
      end

      def ==(other)
        other.city? &&
          @revenue == other.revenue &&
          @slots == other.slots &&
          @id == other.id &&
          @tokens == other.tokens &&
          @reservations == other.reservations
      end

      def <=(other)
        other.city? && (@id == other.id)
      end

      def city?
        true
      end

      def place_token(corporation)
        # the slot is reserved for a different corporation
        slot = @reservations.index(corporation.sym) || @tokens.find_index.with_index do |t, i|
          t.nil? && @reservations[i].nil?
        end

        # a token is already in this slot
        raise unless @tokens[slot].nil?

        # corporation has a reservation for a different spot in the city
        raise unless [nil, slot].include?(@reservations.index(corporation.sym))

        # corporation already placed a token in this city
        raise if @tokens.compact.map(&:corporation).include?(corporation)

        # corporation already placed all their tokens
        raise if corporation.tokens.select(&:unplaced?).empty?

        # place token on this city
        token = corporation.tokens.find(&:unplaced?)
        token.place!
        @tokens[slot] = token
      end

      def coordinates
        @tile&.coordinates
      end
    end
  end
end
