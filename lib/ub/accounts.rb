module Ub
  class Accounts

    extend Forwardable
    def_delegators :@accounts, :[], :size, :count, :each, :select, :collect

    def initialize(interface)
      @interface = interface
      @interface.get('/accounts')
      @accounts = @interface.response['accounts']
    end

    def raw
      @accounts
    end

  end
end
