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


  configure do
    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
    I18n.backend.load_translations
  end

  set :assets_precompile, %w(application.js application.css *.png *.jpg *.svg *.eot *.ttf *.woff)
  set :assets_prefix, %w(app/assets)
  set :assets_css_compressor, :sass
  set :assets_js_compressor, :uglifier

  register Sinatra::AssetPipeline

  @title = "RadioBoot"

  helpers do
    def t(*args)
      # Just a simple alias
      I18n.t(*args)
    end

  end

  before '/:locale/*' do
    I18n.locale = params[:locale]

    if settings.locales.include? params[:locale]
      @locale = params[:locale]
      request.path_info = '/' + params[:splat][0]
    else
      @locale = 'fa'
      request.path_info = "/#{params[:locale]}/#{params[:splat][0]}"
    end
  end

  get '/' do
    # use the views/index.erb file
    @locale ||= "fa"
    erb :'index.html'
  end
end
