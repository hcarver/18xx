# frozen_string_literal: true

require 'snabberb/component'

module View
  module Part
    class MultiRevenue < Snabberb::Component
      COLOR = {
        white: '#fff',
        yellow: '#fde900',
        green: '#71bf44',
        brown: '#cb7745',
        gray: '#bcbdc0',
        red: '#ec232a',
      }.freeze

      needs :revenues

      def render
        children =
          if @revenues.is_a?(Array)
            text = @revenues.join('/')
            [h(:text, {}, text)]
          elsif @revenues.is_a?(Hash)
            @revenues.flat_map.with_index do |rev, index|
              phase, revenue = rev
              text = "#{'D' if phase == :diesel}#{revenue}"

              color = phase == :diesel ? :gray : phase
              fill = COLOR[color]

              width = text.size * 13

              t_x = 26 * index

              rect_attrs = {
                fill: fill,
                transform: "translate(#{t_x} 0)",
                height: 24,
                width: width,
                x: -2,
                y: -18,
              }

              text_attrs = {
                transform: "translate(#{t_x} 0)",
                fill: 'black',
                'font-size': 20,
              }

              [
                h(:rect, attrs: rect_attrs),
                h(:text, { attrs: text_attrs }, text),
              ]
            end
          end

        attrs = {
          class: 'multi_revenue',
          transform: 'translate(-30 0)',
        }

        h(:g, { attrs: attrs }, children)
      end
    end
  end
end
