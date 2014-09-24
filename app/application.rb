require 'json'
require 'xml-sitemap'

# Patch moped to fix openshift IP binding problem
if ENV.include? 'OPENSHIFT_RUBY_IP'

  require 'moped'
  require 'moped/connection'
  require 'moped/connection/socket/connectable'

  module Moped
    class Connection
      module Socket
        class TCP
          def initialize(host, port, local_host)
            @host, @port = host, port
            handle_socket_errors { super(host, port, local_host) }
          end

          def self.connect(host, port, timeout)
            begin
              Timeout::timeout(timeout) do
                sock = new(host, port, ENV['OPENSHIFT_RUBY_IP'])
                sock.set_encoding('binary')
                timeout_val = [ timeout, 0 ].pack("l_2")
                sock.setsockopt(::Socket::IPPROTO_TCP, ::Socket::TCP_NODELAY, 1)
                sock.setsockopt(::Socket::SOL_SOCKET, ::Socket::SO_RCVTIMEO, timeout_val)
                sock.setsockopt(::Socket::SOL_SOCKET, ::Socket::SO_SNDTIMEO, timeout_val)
                sock
              end
            rescue Timeout::Error
              raise Errors::ConnectionFailure, "Timed out connection to Mongo on #{host}:#{port}"
            end
          end
        end
      end
    end
  end
end

require 'mongoid'
require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/asset_pipeline'
require 'i18n'
require 'i18n/backend/fallbacks'
require 'builder'

require 'omniauth-twitter'
require 'omniauth-github'
require 'omniauth-facebook'
require 'omniauth-google-oauth2'

require_relative './lib/mailgun'
require_relative './lib/admin'

require_relative './models/episode'


# Main Sinatra application class
class RadioApp < Sinatra::Application

  set :environment, ENV['RACK_ENV'] || :development

  # Setup configuration variables
  set :root, File.dirname(__FILE__)
  set :locales, ['en', 'fa']

  set :assets_precompile, %w(application.js application_ltr.css application_rtl.css *.png *.jpg *.svg *.eot *.ttf *.woff)
  set :assets_prefix, %w(app/assets)
  set :assets_css_compressor, :sass
  set :assets_js_compressor, :uglifier

  set :mailinglist, 'newsletter@radioboot.com'
  set :mailgun_api_key, ENV['MAILGUN_API_KEY']

  set :admins, {'lxsameer' => 'lxsameer@gnu.org', 'yottanami' => 'yottanami@gmail.com'}

  use Rack::Session::Pool, :expire_after => 2592000

  @title = 'RadioBoot'

  # Enabling features
  #enable :sessions
  enable :logging
  set :session_secret, ENV['SESSION_SECRET'] || 'TODO'

  register Sinatra::AssetPipeline

  include AdminPanel
  # Extra modules
  include Mailgun

  # Configuration
  configure do
    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
    I18n.backend.load_translations

    mime_type :json, 'text/json'
    mime_type :xml, 'text/xml'

    use OmniAuth::Builder do
      provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
      provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
      provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"]

    end
    @app_root = File.expand_path(File.dirname(__FILE__))
    Mongoid.load!(File.join(@app_root, './config/mongoid.yml'), ENV['RACK_ENV'] || :development)
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

    def debug?
      dev = [File.expand_path(File.dirname(__FILE__),
                             '../'), '.development'].join("/")

      return true if File.exist? dev
      false
    end

    # define a current_user method, so we can be sure if an user is authenticated
    def signed_in?
      return true if debug?
      !session[:uid].nil?
    end

    def admin?
      return true if debug?
      return true if settings.admins.values.include? user
      return true if settings.admins.keys.include? user
      false
    end

    def user
      session[:nickname]
    end

    def url_encode(s)
      CGI.escape(s)
    end

  end


  before do
    I18n.locale = session[:local]
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
    session[:locale] = @locale
  end

  before do
    @path = request.path_info
  end

  # Actions

  get '/episodes/:id/' do
    @episode = Episode.where(id: params[:id]).first
    return erb :'404.html' if @episode.nil?
    erb :'episode.html'
  end

  get '/' do
    # use the views/index.erb file
    unless defined? @locale
      @locale = 'fa'
      I18n.locale = 'fa'
    end

    @last_episode = Episode.last
    erb :'index.html'

  end

  get 'download/:type/:id/' do
    begin
      ep = Episode.find(params[:id])
      ep.download += 1
      ep.save
      redirect to(ep.send(params.type.to_sym))
    rescue Mongoid::Errors::DocumentNotFound
      status 404
    end
  end

  get '/feed/' do
    @episodes = Episode.order_by('published_at DESC').limit(20)
    builder :feed
  end

  get '/archive/' do
    @episodes = Episode.order_by('published_at DESC').all
    erb :'archive.html'
  end

  get '/faq/' do
    erb :'faq.html'
  end

  get '/sitemap.xml' do
    content_type :xml

    map = XmlSitemap::Map.new('radioboot.com') do |m|
      # Adds a simple page
      m.add '/episodes'

      # You can drop leading slash, it will be automatically added
      m.add '/archive'
    end

    map.render
  end

  get '/signin/' do
    session[:next] = params[:next]
    erb :'signin.html'
  end

  get '/signout/' do
    session.clear
    redirect to('/')
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

  get '/auth/:service/callback' do
    unless ['github', 'twitter', 'faceboot', 'google_oauth2'].include? params[:service]
      return status 404
    end

    # probably you will need to create a user in the database too...

    session[:uid] = env['omniauth.auth']['uid']
    if params[:service] == 'google_oauth2'
      session[:nickname] = env['omniauth.auth']['info']['email']
      session[:google] = true
    else
      session[:nickname] = env['omniauth.auth']['info']['nickname']
      session[:google] = false
    end
    # this is the main endpoint to your application
    if session[:next]
      session[:next] = nil
      return redirect to(session[:next])
    end
    redirect to('/')
  end

  get '/auth/failure' do
    # omniauth redirects to /auth/failure when it encounters a problem
    # so you can implement this as you please
  end


end
