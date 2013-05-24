module Ub
  class Page

    def initialize(interface, page_id)
      @interface = interface
      @interface.get("/pages/#{page_id}")
      @page = @interface.response
    end

    def raw
      @page
    end

  end
end
