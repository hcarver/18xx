# frozen_string_literal: true

require 'snabberb/component'

require 'view/part/track_curvilinear_path'
require 'view/part/track_lawson_path'

module View
  module Part
    class Track < Snabberb::Component
      needs :tile
      needs :region_use
      needs :route_paths, default: []

      def render_subpart(part_class, **kwargs)
        h(part_class, region_use: @region_use, **kwargs)
      end

      def render_offboards(route_exits)
        @tile.paths.map do |path|
          on_route = route_exits.include?(path.exits.first)
          color = on_route ? 'red' : 'black'

          edge_num = path.edges.first.num

          rotate = 60 * edge_num

          props = {
            attrs: {
              class: 'track',
              transform: "rotate(#{rotate})",
              d: 'M6 75 L 6 85 L -6 85 L -6 75 L 0 48 Z',
              fill: color,
              stroke: 'none',
              'stroke-linecap': 'butt',
              'stroke-linejoin': 'miter',
              'stroke-width': 6,
            }
          }

          h(:path, props)
        end
      end

      def render_lawson(route_exits)
        @tile.exits.flat_map do |e|
          on_route = route_exits.include?(e)
          render_subpart(Part::TrackLawsonPath, edge_num: e, on_route: on_route)
        end
      end

      def render_curvilinear(route_exits)
        full_paths = @tile.paths.select { |p| p.edges.size == 2 }

        full_paths.map do |p|
          on_route = p.exits & route_exits == p.exits
          render_subpart(Part::TrackCurvilinearPath, exits: p.exits, on_route: on_route)
        end
      end

      def render
        return if @tile.exits.empty?

        route_exits = @route_paths.flat_map(&:exits)

        if !@tile.offboards.empty?
          render_offboards(route_exits)
        elsif @tile.lawson?
          render_lawson(route_exits)
        else
          render_curvilinear(route_exits)
        end
      end
    end
  end
end
