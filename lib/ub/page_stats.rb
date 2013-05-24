module Ub
  class PageStats

    extend Forwardable
    def_delegators :@pages, :[], :size, :count, :each, :collect, :select

    def initialize(interface, pages)
      @interface = interface

      @pages = []
      pages.each do |page|
        @interface.get("/pages/#{page['id']}")
        @pages.push(@interface.response)
      end
    end

    def raw
      @pages
    end

  end
end
