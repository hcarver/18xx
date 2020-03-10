# frozen_string_literal: true

require 'view/part/base'

module View
  module Part
    class TrackCurvilinearPath < Base
      SHARP = 1
      GENTLE = 2
      STRAIGHT = 3

      needs :exits
      needs :on_route, default: false

      # returns SHARP, GENTLE, or STRAIGHT
      def compute_curvilinear_type(edge_a, edge_b)
        edge_a, edge_b = edge_b, edge_a if edge_b < edge_a
        diff = edge_b - edge_a
        diff = (edge_a - edge_b) % 6 if diff > 3
        diff
      end

      # degrees to rotate the svg path for this track path; e.g., a normal straight
      # is 0,3; for 1,4, rotate = 60
      def compute_track_rotation_degrees(edge_a, edge_b)
        edge_a, edge_b = edge_b, edge_a if edge_b < edge_a

        if (edge_b - edge_a) > 3
          60 * edge_b
        else
          60 * edge_a
        end
      end

      def preferred_render_locations
        edge_a, edge_b = @exits

        rotation = compute_track_rotation_degrees(edge_a, edge_b)

        [
          {
            regions: { ["edge#{edge_a}", "half_edge#{edge_b}"] => 1 },
            transform: "rotate(#{rotation})",
          }
        ]
      end

      def render_part
        edge_a, edge_b = @exits

        curvilinear_type = compute_curvilinear_type(edge_a, edge_b)

        color = @on_route ? 'red' : 'black'

        d =
          case curvilinear_type
          when SHARP
            'm 0 85 L 0 75 A 43.30125 43.30125 0 0 0 -64.951875 37.5 L -73.612125 42.5'
          when GENTLE
            'm 0 85 L 0 75 A 129.90375 129.90375 0 0 0 -64.951875 -37.5 L -73.612125 -42.5'
          when STRAIGHT
            'm 0 87 L 0 -87'
          else
            raise
          end

        props = {
          attrs: {
            class: 'curvilinear_path',
            transform: transform,
            d: d,
            stroke: color,
            'stroke-width' => 8
          }
        }

        h(:path, props)
      end
    end
  end
end
