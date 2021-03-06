# frozen_string_literal: true

require 'view/token'

module View
  class StockMarket < Snabberb::Component
    needs :stock_market

    def render
      space_style = {
        position: 'relative',
        display: 'inline-block',
        padding: '5px',
        width: '40px',
        height: '40px',
        margin: '0',
        'vertical-align': 'top',
      }

      box_style = space_style.merge(
        width: '38px',
        height: '38px',
        border: 'solid 1px rgba(0,0,0,0.2)',
      )

      grid = @stock_market.market.flat_map do |prices|
        rows = prices.map do |price|
          if price
            style = box_style.merge('background-color' => price.color)

            spacing = 35 / price.corporations.size

            tokens = price.corporations.map.with_index do |corporation, index|
              props = {
                attrs: { data: corporation.logo, width: '25px' },
                style: {
                  position: 'absolute',
                  left: "#{index * spacing}px",
                  'z-index' => -index,
                }
              }
              h(:object, props)
            end

            h(:div, { style: style }, [
              h(:div, price.price),
              h(:div, tokens),
            ])
          else
            h(:div, { style: space_style }, '')
          end
        end

        h(:div, { style: { width: 'max-content' } }, rows)
      end

      props = {
        style: {
          width: '100%',
          overflow: 'auto',
        },
      }
      h(:div, props, grid)
    end
  end
end
