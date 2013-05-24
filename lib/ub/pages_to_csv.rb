module Ub
  class PagesToCsv

    def initialize(pages)
      @pages = pages
      @csv = headlines.to_csv
      @pages.each do |page|
        @csv << to_csv(page)
      end
    end

    def csv
      @csv
    end

    def to_csv(page)
      stats = page['tests']['current']
      array = headlines.collect { |label| stats[label] }
      array.to_csv
    end

    def headlines
      %w(winner
         losers
         id
         hasResults
         champion
         clicks
         conversionRate
         conversionRateDelta
         conversions
         formSubmits
         visitors
         visits)
    end

  end
end
