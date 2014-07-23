require 'json'
require 'multimap'
require 'rest-client'

module Mailgun
  # Helper methods
  def validate_email(email)
    url_params = Multimap.new
    url_params[:address] = email
    query_string = url_params.collect {|k, v| "#{k.to_s}=#{CGI::escape(v.to_s)}"}.
                   join('&')
    RestClient.get "https://api:#{settings.mailgun_api_key}"\
                   "@api.mailgun.net/v2/address/validate?#{query_string}"
  end

  def add_list_member(email)
    begin
      result = RestClient.post("https://api:#{settings.mailgun_api_key}" \
                               "@api.mailgun.net/v2/lists/#{settings.mailinglist}/members",
                               subscribed: true,
                               name: email,
                               description: email,
                               address: email)
      JSON.parse(result)
    rescue RestClient::BadRequest => e
      {'error' => '1',
        'msg' => e.response}
    end
  end

end
