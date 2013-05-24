require 'awesome_print'
require 'csv'
require 'multi_json'
require 'net/https'
require 'optparse'
require 'uri'

require './lib/ub/api'
require './lib/ub/account'
require './lib/ub/accounts'
require './lib/ub/sub_accounts'
require './lib/ub/pages'
require './lib/ub/page'
require './lib/ub/page_stats'
require './lib/ub/pages_to_csv'

require 'sinatra/base'

# Load custom environment variables
load 'env.rb' if File.exists?('env.rb')

class DoorkeeperClient < Sinatra::Base
  enable :sessions

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html

    def pretty_json(json)
      JSON.pretty_generate(json)
    end

    def signed_in?
      !session[:access_token].nil?
    end
  end

  def client(token_method = :post)
    OAuth2::Client.new(
      ENV['OAUTH2_CLIENT_ID'],
      ENV['OAUTH2_CLIENT_SECRET'],
      site:         ENV['SITE'] || "https://api.unbounce.com",
      token_method: token_method,
    )
  end

  def access_token
    OAuth2::AccessToken.new(client, session[:access_token], refresh_token: session[:refresh_token])
  end

  def redirect_uri
    ENV['OAUTH2_CLIENT_REDIRECT_URI']
  end

  get '/' do
    erb :login
  end

  get '/hierarchy_select' do
    erb :hierarchy_select
  end

  get '/page_select' do
    @accounts = Ub::Accounts.new(ubapi)
    @pages = []
    @accounts.each { |a| @pages += Ub::Pages.new(ubapi, account: a['id']).raw }
    erb :page_select
  end

  get '/page/:id' do
    @page = Ub::Page.new(ubapi, params[:id])
    @data = Ub::PageStats.new(ubapi, [@page.raw]).raw
    csv_response(@data)
  end

  get '/sub_account_select' do
    @accounts = Ub::Accounts.new(ubapi)
    @sub_accounts = []
    @accounts.each { |a| @sub_accounts += Ub::SubAccounts.new(ubapi, a['id']).raw }
    erb :sub_account_select
  end

  get '/sub_account/:id' do
    @pages = Ub::Pages.new(ubapi, sub_account: params[:id])
    @data  = Ub::PageStats.new(ubapi, @pages.raw[0..9]).raw
    csv_response(@data)
  end

  get '/account_select' do
    @accounts = Ub::Accounts.new(ubapi)
    erb :account_select
  end

  get '/account/:id' do
    @pages = Ub::Pages.new(ubapi, account: params[:id])
    @data  = Ub::PageStats.new(ubapi, @pages.raw[0..9]).raw
    csv_response(@data)
  end

  get '/all' do
    @accounts = Ub::Accounts.new(ubapi)
    @data = []
    @accounts.each { |a| @data += Ub::Pages.new(ubapi, account: a['id']).raw }
    @data = Ub::PageStats.new(ubapi, @data[0..9]).raw
    csv_response(@data)
  end

  get '/sign_in' do
    scope = params[:scope] # || "public"
    redirect client.auth_code.authorize_url(redirect_uri: redirect_uri) #, scope: scope)
  end

  get '/sign_out' do
    session[:access_token] = nil
    redirect '/'
  end

  get '/callback' do
    new_token = client.auth_code.get_token(params[:code], redirect_uri: redirect_uri)
    session[:access_token]  = new_token.token
    session[:refresh_token] = new_token.refresh_token
    redirect '/hierarchy_select'
  end

  get '/refresh' do
    new_token = access_token.refresh!
    session[:access_token]  = new_token.token
    session[:refresh_token] = new_token.refresh_token
    redirect '/'
  end

  def ubapi
    @ubapi ||= Ub::Api.new(access_token)
  end

  def csv_response(pages)
    headers "Content-Disposition" => "attachment;filename=unbounce_report.csv",
            "Content-Type"        => "application/octet-stream"
    result = Ub::PagesToCsv.new(pages).csv
  end
end
