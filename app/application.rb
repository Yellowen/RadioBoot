require 'sinatra/base'
require 'sinatra/asset_pipeline'

# Main Sinatra application class
class RadioApp < Sinatra::Application
  set :root, File.dirname(__FILE__)
  set :sessions, true

  set :assets_precompile, %w(application.js application.css *.png *.jpg *.svg *.eot *.ttf *.woff)
  set :assets_prefix, %w(app/assets)
  set :assets_css_compressor, :sass
  set :assets_js_compressor, :uglifier
  register Sinatra::AssetPipeline


  @title = "RadioBoot"

  get '/' do
    # use the views/index.erb file
    erb :'index.html'
  end
end
