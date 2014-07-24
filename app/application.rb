require 'json'
require 'sinatra/base'
require 'sinatra/asset_pipeline'
require 'i18n'
require 'i18n/backend/fallbacks'

require_relative './lib/mailgun'

# Main Sinatra application class
class RadioApp < Sinatra::Application

  # Setup configuration variables
  set :root, File.dirname(__FILE__)
  set :locales, ['en', 'fa']

  set :assets_precompile, %w(application.js application.css *.png *.jpg *.svg *.eot *.ttf *.woff)
  set :assets_prefix, %w(app/assets)
  set :assets_css_compressor, :sass
  set :assets_js_compressor, :uglifier

  set :mailinglist, 'newsletter@radioboot.com'
  set :mailgun_api_key, ENV['MAILGUN_API_KEY']

  @title = 'RadioBoot'

  # Enabling features
  enable :sessions
  enable :logging

  register Sinatra::AssetPipeline


  # Extra modules
  include Mailgun

  # Configuration
  configure do
    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
    I18n.backend.load_translations

    mime_type :json, 'text/json'
  end

  # Template helpers
  helpers do
    def t(*args)
      # Just a simple alias
      I18n.t(*args)
    end

    def link_to(url, title, icon)
      if @locale == "en"
        "<a href='#{url}'><i class='#{icon}'></i> #{title}</a>"
      else
        "<a href='#{url}'>#{title} <i class='#{icon}'></i></a>"
      end
    end
  end

  # This section runs before any action with /:locale/ url
  before '/:locale/*' do
    if settings.locales.include? params[:locale]
      @locale = params[:locale]
      I18n.locale = @locale
      request.path_info = '/' + params[:splat][0]
    else
      @locale = 'fa'
      I18n.locale = @locale
      request.path_info = "/#{params[:locale]}/#{params[:splat][0]}"
    end
  end


  # Actions
  get '/' do
    # use the views/index.erb file
    unless defined? @locale
      @locale = 'fa'
      I18n.locale = 'fa'
    end
    erb :'index.html'
  end

  get '/archive/' do
    erb :'archive.html'
  end

  get '/faq/' do
    erb :'faq.html'
  end

  get '/signin/' do
    erb :'signin.html'
  end

  post '/subscribe' do
    content_type :json

    email_validation = JSON.parse(validate_email(params[:email]))
    if email_validation['is_valid'] == true
      member = add_list_member(params[:email])

      return JSON.generate({status: member['error'], msg: member['msg']}) if member.include? 'error'

      if member['member']['subscribed']
        return JSON.generate({status: '0'})
      else
        return JSON.generate({status: '1'})
      end
    else
      return JSON.generate({status: '2'})
    end
  end
end
