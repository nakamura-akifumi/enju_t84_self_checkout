require 'net/http'
require 'uri'
require 'rspec/expectations'
require 'pp'
require 'json'
require 'faraday'
require 'faraday_middleware'
require 'faraday-cookie_jar'
require 'nokogiri'

include RSpec::Matchers

class EnjuAdapter

  attr_accessor :config

  def login
    login_url = "/users/sign_in"

    login_id = @config[:auth][:login_id]
    password = @config[:auth][:password]

    puts "@1 create instance"
    client = Faraday.new(:url => enju_site_url) do |faraday|
      faraday.request  :url_encoded
      #faraday.response :logger
      faraday.use :cookie_jar
      faraday.adapter Faraday.default_adapter
    end

    puts "@2 get authenticity_token (loginform)"
    res = client.get login_url
    doc = Nokogiri::HTML.parse(res.body, nil, 'utf-8')
    token = doc.xpath("//input[@name='authenticity_token']").attribute('value').text

    puts "@3"
    res = client.post login_url, {:user => {:username => login_id, :password => password}, :authenticity_token => token}

    return client
  end

  def checkin(item_identifier)
    checkin_form_url = "/checkins/new"
    checkin_commit_url = "/checkins.json?basket_id="

    client = login

    puts "@4 get authenticity_token (basket form)"
    res = client.get checkin_form_url
    doc = Nokogiri::HTML.parse(res.body, nil, 'utf-8')
    token = doc.xpath('/html/head/meta[@name="csrf-token"]/@content').to_s

    commit_url = doc.xpath("//*[@id='checkin_list']/div[2]/form").attribute('action').text
    # /checkins?basket_id=35
    unless commit_url.match(/basket_id\=(\d*)$/)
      puts "unmatch"
    end
    checkin_commit_url2 = "#{checkin_commit_url}#{$1}"
    puts "match checkin_commit_url2=#{checkin_commit_url2}"

    client.headers['X-Requested-With'] = 'XMLHttpRequest'
    client.headers['X-CSRF-Token'] = token
    res = client.post checkin_commit_url2, {:checkin => {:item_identifier => item_identifier}}
    puts res.body
    # {"item_id":["を入力してください。"],"base":["資料が見つかりません。"]}
  end

  def checkout(user_number, item_identifier)
    checkout_basket_form_url = "/baskets/new"
    checkout_basket_url = "/baskets.json"
    checkout_newitem_form_url = "/checked_items/new"
    checkout_newitem_item_url = "/checked_items.json?basket_id="
    checkout_commit_url = "/baskets/"

    client = login

    puts "@4 get authenticity_token (basket form)"
    res = client.get checkout_basket_form_url
    doc = Nokogiri::HTML.parse(res.body, nil, 'utf-8')
    token = doc.xpath("//input[@name='authenticity_token']").attribute('value').text

    puts "@5"
    res = client.post checkout_basket_url, {:basket => {:user_number => user_number}, :authenticity_token => token}
    json = JSON.parse(res.body)
    basket_id = json['id']

    puts "@6 get authenticity_token (checked item identifier form)"
    res = client.get checkout_newitem_form_url, { :basket_id => basket_id }
    doc = Nokogiri::HTML.parse(res.body, nil, 'utf-8')
    token = doc.xpath("//input[@name='authenticity_token']").attribute('value').text

    puts "@6-2 token=#{token}"
    puts "@7 set item"
    checkout_newitem_item_url2 = "#{checkout_newitem_item_url}#{basket_id}"
    res = client.post checkout_newitem_item_url2, {:checked_item => {:item_identifier => item_identifier}, :authenticity_token => token}
    puts res.body
    # {"base":["この資料はすでに貸し出されています。","この資料の貸出はできません。"]}
    # {"base":["資料が見つかりません。"]}

    checkout_commit_url2 = "#{checkout_commit_url}#{basket_id}"
    puts "@8 #{checkout_commit_url2}"
    res = client.post checkout_commit_url2, {:_method => 'PUT', :authenticity_token => token}
    puts res.body
  end

private
  def enju_site_url
    'http://localhost:3000'
  end
end

c = EnjuAdapter.new
user_number = 'J0001'
item_identifier = 'R00002'

c.config = {:server_url => 'http://localhost:3000', :auth => {:login_id => 'enjuadmin', :password => 'adminpassword'}}
c.checkout(user_number, item_identifier)
c.checkin('R00002')



