require 'sinatra/base'
require 'sinatra/assetpack'

# Main Sinatra application class
class RadioApp < Sinatra::Application
  set :root, File.dirname(__FILE__)

  set :sessions, true

  register Sinatra::AssetPack

  assets {
    serve '/js',     from: 'assets/javascripts'
    serve '/css',    from: 'assets/stylesheets'
    serve '/images', from: 'assets/images'
    serve '/fonts', from: 'assets/fonts'

    # The second parameter defines where the compressed version will be served.
    # (Note: that parameter is optional, AssetPack will figure it out.)
    js :application, '/javascripts/application.js', [
                                                     '/assets/javascript/**/*.js',
                                                    ]

    css :application, '/css/application.css', [
                                               '/assets/stylesheets'
                                              ]

    js_compression  :jsmin    # :jsmin | :yui | :closure | :uglify
    css_compression :simple   # :simple | :sass | :yui | :sqwish
  }

  get '/' do
    # use the views/index.erb file
    erb :'index.html'
  end
end
