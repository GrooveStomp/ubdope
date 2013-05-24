module Ub
  class Pages

    extend Forwardable
    def_delegators :@pages, :[], :size, :count, :each, :select

    def initialize(interface, opts={})
      @interface = interface
      if opts[:account]
        get_from_account(opts[:account])
      elsif opts[:sub_account]
        get_from_sub_account(opts[:sub_account])
      end
    end

    def raw
      @pages
    end

    def get_from_account(id)
      @interface.get("/accounts/#{id}/pages")
      @pages = @interface.response['pages']
    end

    def get_from_sub_account(id)
      @interface.get("/sub_accounts/#{id}/pages")
      @pages = @interface.response['pages']
    end
  end
end
