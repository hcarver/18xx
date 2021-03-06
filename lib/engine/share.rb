# frozen_string_literal: true

require 'engine/ownable'

module Engine
  class Share
    include Ownable

    attr_reader :corporation, :percent, :president

    def self.price(shares)
      shares.sum do |share|
        share.percent / 10 * share.corporation.share_price.price
      end
    end

    def initialize(corporation, owner: nil, president: false, percent: 10, index: 0)
      @corporation = corporation
      @president = president
      @percent = percent
      @owner = owner || corporation
      @index = index
    end

    def id
      "#{@corporation.name}_#{@index}"
    end

    def price
      share_price = @owner == corporation ? corporation.par_price : corporation.share_price
      (share_price&.price || corporation.min_price) * @percent / 10
    end
  end
end
