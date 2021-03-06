require 'net/http'
require 'uri'
require 'json'
require 'faraday'
require 'faraday_middleware'
require 'faraday-cookie_jar'
require 'nokogiri'

class EnjuAdapter

  attr_accessor :config
  attr_accessor :cookie_value

  def initialize
    self.config = {:server_url => 'http://localhost:8080',
                   :auth => {:login_id => 'enjuadmin', :password => 'adminpassword'}}
    self.cookie_value = nil
  end

  def login(session)
    login_url = "/users/sign_in"

    login_id = @config[:auth][:login_id]
    password = @config[:auth][:password]
    server_url = @config[:server_url]

    logger.debug "@1 create instance server_url=#{server_url}"
    client = Faraday.new(:url => server_url) do |faraday|
      faraday.request  :url_encoded
      #faraday.response :logger
      faraday.use :cookie_jar
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
      faraday.token_auth('authentication-token')
    end

    logger.debug "@2 get authenticity_token (loginform)"
    res = client.get login_url
    doc = Nokogiri::HTML.parse(res.body, nil, 'utf-8')
    token = doc.xpath("//input[@name='authenticity_token']").attribute('value').text rescue ''
    if token.blank?
      logger.info "not find authenticity_token"
      puts doc
    end

    set_cookie = res.headers["Set-Cookie"]
    @jar = HTTP::CookieJar.new
    @jar.parse(set_cookie, res.env[:url])
    cookies = @jar.cookies('http://localhost:8080')
    @cookie_value = HTTP::Cookie.cookie_value(cookies)

    logger.debug "@22"
    logger.debug res.headers

    logger.debug "@3 login"
    res = client.post login_url, {:user => {:username => login_id, :password => password}, :authenticity_token => token}

    return client
  end

  def checkin(item_identifier, session = nil)
    checkin_form_url = "/checkins/new"
    checkin_commit_url = "/checkins.json?basket_id="

    client = login(session)

    logger.debug  "@4 get authenticity_token (basket form)"
    res = client.get checkin_form_url
    doc = Nokogiri::HTML.parse(res.body, nil, 'utf-8')
    token = doc.xpath('/html/head/meta[@name="csrf-token"]/@content').to_s

    commit_url = doc.xpath("//*[@id='checkin_list']/div[2]/form").attribute('action').text
    # /checkins?basket_id=35
    unless commit_url.match(/basket_id\=(\d*)$/)
      logger.debug  "unmatch"
    end
    checkin_commit_url2 = "#{checkin_commit_url}#{$1}"
    logger.debug  "match checkin_commit_url2=#{checkin_commit_url2}"

    client.headers['X-Requested-With'] = 'XMLHttpRequest'
    client.headers['X-CSRF-Token'] = token
    res = client.post checkin_commit_url2, {:checkin => {:item_identifier => item_identifier}}

    return JSON.parse(res.body)
  end


  def get_checkout_basket(user_number, session = nil)
    checkout_basket_form_url = "/baskets/new"
    checkout_basket_url = "/baskets.json"

    client = login(session)

    logger.debug "@4 get authenticity_token (basket form)"
    res = client.get checkout_basket_form_url
    doc = Nokogiri::HTML.parse(res.body, nil, 'utf-8')
    token = doc.xpath("//input[@name='authenticity_token']").attribute('value').text

    logger.debug "@5 create new basket"
    res = client.post checkout_basket_url, {:basket => {:user_number => user_number}, :authenticity_token => token}
    json = JSON.parse(res.body)
    basket_id = json['id']

    return basket_id
  end

  def add_checkout_item(session_value, basket_id, item_identifier)
    checkout_newitem_form_url = "/checked_items/new"
    checkout_newitem_item_url = "/checked_items.json?basket_id="

    client = login(session_value)

    logger.debug "@6 get authenticity_token (checked item identifier form)"
    res = client.get checkout_newitem_form_url, { :basket_id => basket_id }
    doc = Nokogiri::HTML.parse(res.body, nil, 'utf-8')
    token = doc.xpath("//input[@name='authenticity_token']").attribute('value').text

    logger.debug "@6-2 token=#{token}"
    logger.debug "@7 set item"
    checkout_newitem_item_url2 = "#{checkout_newitem_item_url}#{basket_id}"
    res = client.post checkout_newitem_item_url2, {:checked_item => {:item_identifier => item_identifier}, :authenticity_token => token}

    return res

  end

  def checkout(session_value, basket_id)
    checkout_newitem_form_url = "/checked_items/new"
    checkout_commit_url = "/baskets/"

    client = login(session_value)

    logger.debug "@6 get authenticity_token (checked item identifier form)"
    res = client.get checkout_newitem_form_url, { :basket_id => basket_id }
    doc = Nokogiri::HTML.parse(res.body, nil, 'utf-8')
    token = doc.xpath("//input[@name='authenticity_token']").attribute('value').text

    checkout_commit_url2 = "#{checkout_commit_url}#{basket_id}.json"
    logger.debug "@8 #{checkout_commit_url2}"
    res = client.post checkout_commit_url2, {:_method => 'PUT', :authenticity_token => token}
    return res
  end

  private
  def logger
    Rails.logger
  end

end
