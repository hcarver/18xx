# frozen_string_literal: true

module Engine
  class Hex
    attr_reader :coordinates, :layout, :tile, :x, :y, :location_name

    DIRECTIONS = {
      flat: {
        [0, 2] => 0,
        [-1, 1] => 1,
        [-1, -1] => 2,
        [0, -2] => 3,
        [1, -1] => 4,
        [1, 1] => 5,
      },
      pointy: {
        [1, 1] => 0,
        [-1, 1] => 1,
        [-2, 0] => 2,
        [-1, -1] => 3,
        [1, -1] => 4,
        [2, 0] => 5,
      },
    }.freeze

    LETTERS = ('A'..'Z').to_a

    # Coordinates are of the form A1..Z99
    # x and y map to the double coordinate system
    # layout is pointy or flat
    def initialize(coordinates, layout: :pointy, tile: nil, location_name: nil)
      @coordinates = coordinates
      @layout = layout
      @x = LETTERS.index(@coordinates[0]).to_i
      @y = @coordinates[1..-1].to_i - 1
      @location_name = location_name
      lay(tile)
    end

    def name
      @coordinates
    end

    def lay(tile)
      # when upgrading, preserve tokens (both reserved and actually placed) on
      # previous tile
      @tile&.cities&.each_with_index do |city, i|
        tile.cities[i].reservations = city.reservations.dup

        city.tokens.each do |token|
          tile.cities[i].place_token(token.corporation) if token
        end
      end

      # give the city/town name of this hex to the tile
      tile&.location_name = @location_name

      tile.coordinates = @coordinates

      @tile = tile
    end

    def direction(other)
      [other.x - @x, other.y - @y]
    end

    def neighbor_direction(other)
      DIRECTIONS[@layout][direction(other)]
    end

    def connections(other)
      dir = neighbor_direction(other)
      idir = invert(dir)

      # this current assumes there's only one valid route to an exit which may not be true
      @tile.paths.select { |p| p.exits.include?(dir) } +
        other.tile.paths.select { |p| p.exits.include?(idir) }
    end

    def connected?(other)
      dir = neighbor_direction(other)
      @tile.exits.include?(dir) && other.tile.exits.include?(invert(dir))
    end

    def invert(dir)
      (dir + 3) % 6
    end

    def ==(other)
      @coordinates == other&.coordinates
    end
  end
end
