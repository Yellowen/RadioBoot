require 'json'
require 'sinatra/base'
require 'sinatra/asset_pipeline'
require 'i18n'
require 'i18n/backend/fallbacks'

# Main Sinatra application class
class RadioApp < Sinatra::Application
  set :root, File.dirname(__FILE__)
  set :locales, ["en", "fa"]

  enable :sessions
  enable :logging

  set :assets_precompile, %w(application.js application.css *.png *.jpg *.svg *.eot *.ttf *.woff)
  set :assets_prefix, %w(app/assets)
  set :assets_css_compressor, :sass
  set :assets_js_compressor, :uglifier

  register Sinatra::AssetPipeline


  configure do
    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
    I18n.backend.load_translations

    mime_type :json, 'text/json'
  end

  @title = 'RadioBoot'

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


  post '/subscribe' do
    content_type :json

    JSON.generate({status: 200})
  end
end
