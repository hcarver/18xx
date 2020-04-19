# frozen_string_literal: true

module Engine
  module ShareHolder
    def shares
      shares_by_corporation.values.flatten
    end

    def shares_by_corporation
      @shares_by_corporation ||= Hash.new { |h, k| h[k] = [] }
    end

    def shares_of(corporation)
      return [] unless corporation

      shares_by_corporation[corporation]
    end

    def percent_of(corporation)
      return 0 unless corporation

      shares_by_corporation[corporation].sum(&:percent)
    end

    def num_shares_of(corporation)
      percent_of(corporation) / 10
    end
  end
end
