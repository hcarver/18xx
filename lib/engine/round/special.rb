# frozen_string_literal: true

require 'engine/action/lay_tile'
require 'engine/corporation'
require 'engine/player'
require 'engine/round/base'

module Engine
  module Round
    class Special < Base
      def active_entities
        @entities
      end

      def current_entity=(new_entity)
        @current_entity = new_entity
        @layable_hexes = nil
      end

      def tile_laying_ability
        return {} unless (ability = @current_entity&.abilities(:tile_lay))

        ability
      end

      def layable_hexes
        @layable_hexes ||= tile_laying_ability[:hexes]&.map do |coordinates|
          hex = @game.hex_by_id(coordinates)
          [hex, hex.neighbors.keys]
        end.to_h
      end

      def legal_rotations(hex, tile)
        original_exits = hex.tile.exits

        (0..5).select do |rotation|
          exits = tile.exits.map { |e| tile.rotate(e, rotation) }
          ((original_exits & exits).size == original_exits.size) &&
            exits.all? { |direction| hex.neighbors[direction] }
        end
      end

      private

      def _process_action(action)
        company = action.entity
        case action
        when Action::LayTile
          lay_tile(action)
          company.remove_ability(:tile_lay)
        when Action::BuyShare
          owner = company.owner
          share = action.share
          corporation = share.corporation
          @game.share_pool.transfer_share(share, owner)
          @log << "#{owner.name} exchanges #{company.name} for a share of #{corporation.name}"
          presidential_share_swap(corporation, owner) if corporation.owner != owner
          company.close!
        end
      end

      def potential_tiles
        tile_laying_ability[:tiles]&.map do |name|
          # this is shit
          @game.tiles.find { |t| t.name == name }
        end
      end
    end
  end
end
