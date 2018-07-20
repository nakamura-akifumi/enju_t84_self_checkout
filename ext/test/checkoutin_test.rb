require 'net/http'
require 'uri'
require 'rspec/expectations'
require 'pp'
require 'json'

include RSpec::Matchers

class CheckoutinTest

  SERVER_URL = 'http://localhost:3000/self_iccards/t'

  def post(post_param)
    url = URI.parse(SERVER_URL)
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data(post_param)
    res = Net::HTTP.new(url.host, url.port).start do |http|
      http.request(req)
    end

    unless res.code.to_s == 200
      #raise "server return code error not 200 (#{res.code})"
    end

    return JSON.parse(res.body)
  end

end


c = CheckoutinTest.new

puts "test 1: no cert(1)"
j = c.post({})
expect(j['status']).to eq 400
expect(j['errors'].size).to eq 1
error = j['errors'].first
expect(error['status']).to eq 400
expect(error['message']).to eq 'no cert'

puts "test 2: no cert(2)"
j = c.post({'from' => '2005-01-01', 'to' => '2010-01-01'})
expect(j['status']).to eq 400
expect(j['errors'].size).to eq 1
error = j['errors'].first
expect(error['status']).to eq 400
expect(error['message']).to eq 'no cert'

puts "test 3: no event"
j = c.post({'cert' => 'randomteststrings'})
expect(j['status']).to eq 400
expect(j['errors'].size).to eq 1
error = j['errors'].first
expect(error['status']).to eq 401
expect(error['message']).to eq 'no event'

puts "test 4: unknown event"
j = c.post({'cert' => 'randomteststrings', 'event' => 'foobarbaz'})
expect(j['status']).to eq 400
expect(j['errors'].size).to eq 1
error = j['errors'].first
expect(error['status']).to eq 402
expect(error['message']).to eq 'unknown event'

puts "test 5: cardid2userid parameter error [no tag]"
j = c.post({'cert' => 'randomteststrings', 'event' => 'cardid2userid'})
expect(j['status']).to eq 400
expect(j['errors'].size).to eq 1
error = j['errors'].first
expect(error['status']).to eq 500
expect(error['message']).to eq 'no tag'

puts "test 6: cardid2userid parameter error [invalid tag]"
j = c.post({'cert' => 'randomteststrings', 'event' => 'cardid2userid', 'tag' => 'aaaa'})
expect(j['status']).to eq 400
expect(j['errors'].size).to eq 1
error = j['errors'].first
expect(error['status']).to eq 501
expect(error['message']).to eq 'invalid tag'

puts "test 7: cardid2userid success transfer"
j = c.post({'cert' => 'randomteststrings', 'event' => 'cardid2userid', 'tag' => '0114349e9c12280c'})
expect(j['status']).to eq 200
expect(j['errors']).to eq nil
expect(j['results'].size).to eq 1
r = j['results'].first
expect(r['name']).to eq '中村晃史'
expect(r['user_number']).to eq 'J0001'

puts "test 8: checkout parameter error [no user_number]"
j = c.post({'cert' => 'randomteststrings', 'event' => 'checkout', 'tag' => '0114349e9c12280c'})
expect(j['status']).to eq 400
expect(j['errors'].size).to eq 1
error = j['errors'].first
expect(error['status']).to eq 520
expect(error['message']).to eq 'no user_number'

puts "test 9: checkout parameter error [invalid user_number]"
j = c.post({'cert' => 'randomteststrings', 'event' => 'checkout', 'user_number' => '0114349e9c12280c'})
expect(j['status']).to eq 400
expect(j['errors'].size).to eq 1
error = j['errors'].first
expect(error['status']).to eq 521
expect(error['message']).to eq 'invalid user_number'

puts "test 10: checkout parameter error [no item_identifier]"
j = c.post({'cert' => 'randomteststrings', 'event' => 'checkout',
            'user_number' => 'J0001'})
expect(j['status']).to eq 400

puts "test 11: checkout parameter error [invalid item_identifier]"
j = c.post({'cert' => 'randomteststrings', 'event' => 'checkout',
            'user_number' => 'J0001', 'item_identifier' => 'aaaa'})
expect(j['status']).to eq 400

puts "test 12: checkout success"
j = c.post(
    {'cert' => 'randomteststrings', 'event' => 'checkout',
                'user_number' => 'J0001', 'item_identifier' => 'R00001'})
expect(j['status']).to eq 200








