# frozen_string_literal: true

require 'view/part/base'
require 'view/part/multi_revenue'

module View
  module Part
    class Revenue < Base
      needs :tile

      def preferred_render_locations
        if @slots >= 5
          return [
            {
              regions: ['center'],
              transform: 'translate(0 0)',
            }
          ]
        end

        [
          {
            regions: ['center'],
            transform: 'translate(0 0)',
          },
          {
            regions: ['corner0.5'],
            transform: 'translate(-41 71)',
          }
        ]
      end

      def parse_tile
        revenue_stops = @tile.cities + @tile.towns + @tile.offboards
        revenues = revenue_stops.map(&:revenue)
        @revenue = revenues.first if revenues.uniq == revenues

        @slots = @tile.cities.map(&:slots).sum
      end

      def should_render?
        ![nil, 0, [0], {}, []].include?(@revenue)
      end

      def render_part
        text_attrs = {
          fill: 'black',
          transform: 'translate(0 6)',
          'text-anchor': 'middle',
        }

        if @revenue.is_a?(Numeric)
          attrs = {
            class: 'revenue',
            'stroke-width': 1,
            transform: transform,
          }

          h(
            :g,
            { attrs: attrs },
            [
              h(:circle, attrs: { r: 14, fill: 'white' }),
              h(:text, { attrs: text_attrs }, @revenue),
            ]
          )
        else
          h(Part::MultiRevenue, revenues: @revenue)
        end
      end
    end
  end
end
