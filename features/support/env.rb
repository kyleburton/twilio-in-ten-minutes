require 'rubygems'
require 'date'
require 'digest/sha1'
require 'hpricot'
require 'json'
require 'net/http'
require 'net/https'
require 'openssl'
require 'uri'

begin
  require 'rspec/expectations'
rescue LoadError
  require 'spec/expectations'
end

IVR_ENVIRONMENT = (ENV['IVR_ENVIRONMENT'] || 'development').to_sym

IVR_ENVIRONMENTS = {
  :development => {
    :base_url => 'http://localhost.localdomain:3000'
  },
  :production => {
    :base_url => 'http://warm-wind-609.heroku.com'
  },
}

class IvrClient 
  attr_accessor :phone_number, :ivr_phone_number, :workflow_name, :last_response
  def config; IVR_ENVIRONMENTS[IVR_ENVIRONMENT]; end

  def init_http
    @uri = URI.parse config[:base_url]
    @ua = Net::HTTP.new(@uri.host,@uri.port)
    if @uri.port == 443 || @uri.scheme == 'https'
      @ua.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @ua.use_ssl = true
    end
    @ua.start
  end

  def generate_new_call_sid
    @call_sid = 'cuke-sid-' + Time.now.to_i.to_s + '-' + rand(1_000_000).to_i.to_s
  end

  def initialize
    init_http
    @ivr_phone_number = '(415) 599-2671'
    generate_new_call_sid
  end

  def check_http_resp resp
    case resp
    when Net::HTTPOK then true
    else
      raise "Error, not a 200 OK : #{resp.inspect}"
    end
    resp
  end

  def req_params params={}
    params['CallSid']     ||= @call_sid
    params['Digits']      ||= ''
    params['AccountSid']  ||= (@account_sid || 'none-configured')
    params['From']        ||= @phone_number
    params['To']          ||= @ivr_phone_number
    params['Direction']   ||= 'inbound'
    params['FromCity']    ||= ''
    params['FromState']   ||= ''
    params['FromZip']     ||= ''
    params['FromCountry'] ||= ''
    params['ToCity']      ||= ''
    params['ToState']     ||= ''
    params['ToZip']       ||= ''
    params['ToCountry']   ||= ''
    params
  end

  def req_params_to_qs params={}
    qs = []
    req_params(params).each do |k,v|
      qs << [URI.escape(k),URI.escape(v)].join('=')
    end
    qs.join("&")
  end


  def do_get url, type='json'
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.path)
    if config[:basic_auth]
      req.basic_auth config[:basic_auth][:user], config[:basic_auth][:pass]
    end
    resp = check_http_resp @ua.request(req)
    case type
    when 'json'
      JSON.parse(resp.body)
    else
      resp.body
    end
  end

  def do_post url, params, type='json'
    uri = URI.parse(url)
    req = Net::HTTP::Post.new(uri.path)
    if config[:basic_auth]
      req.basic_auth config[:basic_auth][:user], config[:basic_auth][:pass]
    end
    #puts "Setting form data: #{params.inspect}"
    req.set_form_data(params)
    resp = check_http_resp @ua.request(req)
    case type
    when 'json'
      JSON.parse(resp.body)
    else
      resp.body
    end
  end

  def input_to_workflow params={}
    url = "#{config[:base_url]}/workflow/input/#{workflow_name}.json"
    @last_response = do_post url, req_params(params)
  end

  def call_the_ivr
    input_to_workflow
  end

  def sms_req_params params={}
    params['AccountSid']  ||= (@account_sid || 'none-configured')
    params['From']        ||= @phone_number
    params['To']          ||= @sms_phone_number
    params["SmsSid"]      ||= ''
    params["Body"]        ||= ''
    params['Direction']   ||= 'inbound'
    params['FromCity']    ||= ''
    params['FromState']   ||= ''
    params['FromZip']     ||= ''
    params['FromCountry'] ||= ''
    params['ToCity']      ||= ''
    params['ToState']     ||= ''
    params['ToZip']       ||= ''
    params['ToCountry']   ||= ''


    params
  end

  def send_sms params
  end

end

ivr_client = IvrClient.new

Before do
  @ivr_client = ivr_client
end

After do
end
