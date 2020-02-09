# frozen_string_literal: true

require 'engine/game_error'
require 'engine/part/city'
require 'engine/part/town'
require 'engine/part/edge'
require 'engine/part/junction'
require 'engine/part/label'
require 'engine/part/path'
require 'engine/part/upgrade'

module Engine
  class Tile
    # * [t]own    - [r]evenue, [id] (default: 0)
    # * [c]ity    - [r]evenue, [id] (default: 0), [s]lots (default 1); some
    #               slots may be reser[v]ed by referencing a corporation's short
    #               name/@sym (multiple corporation reservations separated by "+")
    # * [p]ath    - endpoints [a] and [b]; the endpoints can be an edge number,
    #               town/city reference, or a lawson-style [j]unction
    # * [l]abel   - large letters on tile
    # * [u]pgrade - [c]ost, [t]errain (multiple terrain types separated by "+"),
    #               [e]dge (if not specified, then the upgrade applies to the
    #               tile and is rendered in the center)

    WHITE = {
      'blank' => '',
      'town' => 't=r:0',
      'city' => 'c=r:0',
      'mtn80' => 'u=c:80,t:mountain',
      'wtr80' => 'u=c:80,t:water',
      'mtn+wtr80' => 'u=c:80,t:mountain+water',
    }.freeze

    YELLOW = {
      '1' => 't=r:10,id:0;p=a:0,b:_0;p=a:_0,b:4;t=r:10,id:1;p=a:1,b:_1;p=a:_1,b:3',
      '3' => 't=r:10;p=a:0,b:_0;p=a:_0,b:1',
      '4' => 't=r:10;p=a:0,b:_0;p=a:_0,b:3',
      '5' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:1',
      '6' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:2',
      '7' => 'p=a:0,b:5',
      '8' => 'p=a:0,b:4',
      '9' => 'p=a:0,b:3',
      '57' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:3',
      '58' => 't=r:10;p=a:0,b:_0;p=a:_0,b:2',
      '437' => 't=r:30;p=a:0,b:_0;p=a:_0,b:2;l=P',
      '438' => 'c=r:40;p=a:0,b:_0;p=a:_0,b:2;l=H;u=c:80',
    }.freeze

    GREEN = {
      '12' => 'c=r:30;p=a:0,b:_0;p=a:1,b:_0;p=a:5,b:_0',
      '13' => 'c=r:30;p=a:0,b:_0;p=a:2,b:_0;p=a:4,b:_0',
      '14' => 'c=r:30,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:3,b:_0;p=a:4,b:_0',
      '15' => 'c=r:30,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0',
      '16' => 'p=a:0,b:4;p=a:1,b:5',
      '18' => 'p=a:0,b:3;p=a:1,b:2',
      '19' => 'p=a:0,b:3;p=a:1,b:5',
      '20' => 'p=a:0,b:3;p=a:1,b:4',
      '23' => 'p=a:0,b:3;p=a:0,b:4',
      '24' => 'p=a:0,b:3;p=a:0,b:2',
      '25' => 'p=a:0,b:2;p=a:0,b:4',
      '26' => 'p=a:0,b:3;p=a:0,b:5',
      '27' => 'p=a:0,b:3;p=a:0,b:1',
      '28' => 'p=a:0,b:4;p=a:0,b:5',
      '29' => 'p=a:0,b:1;p=a:0,b:2',
      '81A' => 'p=a:0,b:j;p=a:2,b:j;p=a:4,b:j',
      '205' => 'c=r:30;p=a:0,b:_0;p=a:1,b:_0;p=a:3,b:_0',
      '206' => 'c=r:30;p=a:0,b:_0;p=a:3,b:_0;p=a:5,b:_0',
      '298' => 'c=r:40,id:0;c=r:40,id:1;c=r:40,id:2;c=r:40,id:3;l=Chi;'\
               'p=a:1,b:_0;p=a:0,b:_1;p=a:5,b:_2;p=a:4,b:_3;'\
               'p=a:_0,b:3;p=a:_2,b:3;p=a:_3,b:3;p=a:_1,b:3',
      '439' => 'c=r:60,s:2;p=a:0,b:_0;p=a:2,b:_0;p=a:4,b:_0;l=H;u=c:80',
      '440' => 'c=r:40,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;l=T',
    }.freeze

    BROWN = {
      '39' => 'p=a:0,b:1;p=a:0,b:2;p=a:1,b:2',
      '40' => 'p=a:0,b:2;p=a:0,b:4;p=a:2,b:4',
      '41' => 'p=a:0,b:3;p=a:0,b:4;p=a:3,b:4',
      '42' => 'p=a:0,b:3;p=a:0,b:2;p=a:2,b:3',
      '45' => 'p=a:0,b:3;p=a:0,b:5;p=a:1,b:3;p=a:1,b:5',
      '46' => 'p=a:0,b:1;p=a:0,b:3;p=a:1,b:5;p=a:3,b:5',
      '47' => 'p=a:0,b:2;p=a:0,b:3;p=a:2,b:5;p=a:3,b:5',
      '448' => 'c=r:40,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0',
      '465' => 'c=r:40,s:2;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=K',
      '466' => 'c=r:60,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;l=T',
      '492' => 'c=r:80,s:3;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=H',
      '611' => 'c=r:40,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;',
      'W5' => 'c=r:50,s:6;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0',
    }.freeze

    GRAY = {
      '456' => 'c=r:70,s:5;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0',
      '639' => 'c=r:100,s:4;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0',
    }.freeze

    RED = {}.freeze

    COLORS = %i[white yellow green brown gray].freeze

    attr_accessor :location_name
    attr_reader :cities, :color, :edges, :junctions, :label, :name,
                :parts, :paths, :rotation, :towns, :upgrades

    def self.for(name, **opts)
      if (code = WHITE[name])
        color = :white
      elsif (code = YELLOW[name])
        color = :yellow
      elsif (code = GREEN[name])
        color = :green
      elsif (code = BROWN[name])
        color = :brown
      elsif (code = GRAY[name])
        color = :gray
      elsif (code = RED[name])
        color = :red
      else
        raise Engine::GameError, "Tile '#{name}' not found"
      end

      from_code(name, color, code, **opts)
    end

    def self.decode(code)
      cache = []

      code.split(';').map do |part_code|
        type, params = part_code.split('=')

        params = params.split(',').map { |param| param.split(':') }.to_h if params.include?(':')

        part(type, params, cache)
      end
    end

    def self.from_code(name, color, code, **opts)
      Tile.new(name, color: color, parts: decode(code), **opts)
    end

    def self.part(type, params, cache)
      case type
      when 'p'
        params = params.map do |k, v|
          case v[0]
          when '_'
            [k, cache[v[1..-1].to_i]]
          when 'j'
            [k, Part::Junction.new]
          else
            [k, Part::Edge.new(v)]
          end
        end.to_h

        Part::Path.new(params['a'], params['b'])
      when 'c'
        city = Part::City.new(params['r'], params.fetch('s', 1), params['id'], params['v']&.split('+'))
        cache << city
        city
      when 't'
        town = Part::Town.new(params['r'], params['id'])
        cache << town
        town
      when 'l'
        label = Part::Label.new(params)
        cache << label
        label
      when 'u'
        upgrade = Part::Upgrade.new(params['c'], params['t']&.split('+'))
        cache << upgrade
        upgrade
      end
    end

    # rotation 0-5
    def initialize(name, color:, parts:, rotation: 0)
      @name = name
      @color = color
      @parts = parts
      @rotation = rotation
      @cities = []
      @paths = []
      @towns = []
      @edges = nil
      @junctions = nil
      @upgrades = []
      @location_name = nil
      separate_parts
      rotate_edges!(rotation)
    end

    def rotate!
      @rotation = rotate(@rotation)
      rotate_edges!
    end

    def rotate(num, ticks = 1)
      (num + ticks) % 6
    end

    def exits
      @exits ||= @edges.map(&:num).uniq
    end

    def lawson?
      @lawson ||= @junctions.any?
    end

    def ==(other)
      @name == other.name && @color == other.color && @parts == other.parts
    end

    def upgrades_to?(other)
      # correct color progression?
      return false unless COLORS.index(other.color) == (COLORS.index(@color) + 1)

      # correct label?
      return false unless label == other.label

      # honors existing town/city counts?
      # TODO: this is not true for some OO upgrades, or some tiles where
      # double-town can be upgraded into a single town
      return false unless @towns.size == other.towns.size
      return false unless @cities.size == other.cities.size

      # honors pre-existing track?
      return false unless paths_are_subset_of?(other.paths)

      true
    end

    def paths_are_subset_of?(other_paths)
      (0..5).any? do |ticks|
        @paths.all? do |path|
          path = path.rotate(ticks)
          other_paths.any? { |other| path <= other }
        end
      end
    end

    private

    def rotate_edges!(ticks = 1)
      @exits = nil
      @edges.each { |e| e.num = rotate(e.num, ticks) }
    end

    def separate_parts
      @parts.each do |part|
        if part.city?
          @cities << part
        elsif part.label?
          @label = part
        elsif part.path?
          @paths << part
        elsif part.town?
          @towns << part
        elsif part.upgrade?
          @upgrades << part
        else
          raise "Part #{part} not separated."
        end
      end

      @junctions = @paths.flat_map(&:junctions)
      @edges = @paths.flat_map(&:edges)
    end
  end
end
