module Ub
  class Account

    extend Forwardable
    def_delegators :@account, :[], :each, :count

    def initialize(interface, account_id)
      @interface = interface
      accounts = Ub::Accounts.new(interface)
      @account = accounts.select { |a| a['id'] == account_id.to_i }
    end

    def raw
      @account
    end

  end
end
