module Ub
  class SubAccounts

    extend Forwardable
    def_delegators :@sub_accounts, :[], :size, :count, :each, :select

    def initialize(interface, account_id)
      @interface = interface
      @interface.get("/accounts/#{account_id}/sub_accounts/")
      @sub_accounts = @interface.response['subAccounts']
    end

    def raw
      @sub_accounts
    end
  end
end
