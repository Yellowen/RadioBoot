#encoding: utf-8
module AdminPanel


  def self.included(base)
    base.set :admins, {'lxsameer' => 'lxsameer@gnu.org', 'yottanami' => 'yottanami@gnu.org'}


    base.before '/admin/' do
      # we do not want to redirect to twitter when the path info starts
      # with /auth/
      pass if request.path_info =~ /^\/auth\//

      # /auth/twitter is captured by omniauth:
      # when the path info matches /auth/twitter, omniauth will redirect to twitter
      redirect to('/signin/') unless signed_in?
    end

    base.get '/admin/' do
      return redirect to('/signin/?next=/admin/') unless signed_in?
      return erb :'403.html' unless admin?

      if session[:flash]
        @flash = session[:flash]
        session[:flash] = nil
      end

      if session[:errors]
        @errors = session[:errors]
        session[:errors] = nil
      end

      if session[:episode]
        @episode = session[:episode]
        session[:episode] = nil
      end

      @episode ||= Episode.new
      @episodes = Episode.order_by('episode_number DESC').all
      erb :'admin.html'
    end

    base.get '/admin/:id/edit' do
      return redirect to('/signin/?next=/admin/') unless signed_in?
      return erb :'403.html' unless admin?

      begin
        session[:episode] = Episode.find(params[:id])
      rescue Mongoid::Errors::DocumentNotFound
        session[:flash] = {type: "error", msg: t(:item_notfound)}
      end

      redirect to('/admin/')
    end

    base.get '/admin/:id/remove' do
      return redirect to('/signin/?next=/admin/') unless signed_in?
      return erb :'403.html' unless admin?

      begin
        ep = Episode.find(params[:id])
        ep.destroy
        session[:flash] = {type: "success", msg: t(:delete_success)}
      rescue Mongoid::Errors::DocumentNotFound
        session[:flash] = {type: "error", msg: t(:item_notfound)}
      end

      redirect to('/admin/')
    end

    base.post '/admin/save' do
      return redirect to('/signin/?next=/admin/') unless signed_in?
      return erb :'403.html' unless admin?

      begin
        @episode = Episode.find(params[:id])
      rescue Mongoid::Errors::DocumentNotFound
        @episode = Episode.new
      end

      locale = I18n.locale
      I18n.locale = params[:locale].to_s.downcase.to_sym
      @episode.title = params[:title]
      I18n.locale = locale
      @episode.episode_number = params[:episode]
      @episode.mp3_url = params[:mp3_url]
      @episode.ogg_url = params[:ogg_url]
      @episode.tags = params[:tags].split(',')
      #@episode.publish_at = Date.today

      if @episode.save
        session[:flash] = {type: 'success', msg: t(:episode_saved)}
      else
        session[:flash] = {type: 'error', msg: t(:episode_failed)}
        session[:errors] = @episode.errors
        session[:episode] = @episode
      end

      redirect to('/admin/')
    end

    base.post '/admin/upload' do
      begin
        data = JSON.parse(params[:json].force_encoding('utf-8'))
        ep = Episode.find(params[:id])
        ep.details = data
        ep.save
        JSON.generate({status: '0'})
      rescue JSON::ParserError => e
        JSON.generate({status: '1', msg: e.to_s})
      rescue Encoding::UndefinedConversionError => e
        JSON.generate({status: '1', msg: e.to_s})
      rescue Exception => e
        JSON.generate({status: '1', msg: e.to_s})
      end
    end
  end

end
