# frozen_string_literal: true

require 'engine/action/base'

module Engine
  module Action
    class Bid < Base
      attr_reader :company, :price

      def initialize(entity, company, price)
        @entity = entity
        @company = company
        @price = price
      end

      def self.h_to_args(h, game)
        [game.company_by_id(h['company']), h['price']]
      end

      def args_to_h
        {
          'company' => @company.id,
          'price' => @price,
        }
      end
    end
  end
end
