# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class Blocker < Base
      needs :tile

      def preferred_render_locations
        [
          {
            regions: ['corner3.5'],
            transform: 'translate(-70 5)',
          }
        ]
      end

      def parse_tile
        @blocker = @tile.blockers.first
        @text = @blocker&.sym
      end

      def should_render?
        !(@blocker.nil? || !@blocker.open? || @blocker.owned_by_corporation?)
      end

      def render_part
        h(:g,
          { attrs: { transform: transform, class: 'blocker', } },
          [
            h(:text,
              { attrs: { fill: 'black',
                         'dominant-baseline': 'baseline',
                         'text-anchor': 'middle',
                         x: 0,
                         y: -5 } },
              @text),
            h(:path, { attrs: { fill: 'white', d: 'M -11 6 A 44 44 0 0 0 11 6' } }, @text),
            h(:circle, { attrs: { fill: 'white', r: 6, cx: 11, cy: 6 } }, @text),
            h(:circle, { attrs: { fill: 'white', r: 6, cx: -11, cy: 6 } }, @text),
          ])
      end
    end
  end
end
