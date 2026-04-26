require 'net/http'
require 'json'

user = User.first
token = JwtService.encode(user_id: user.id) rescue nil

uri = URI('http://localhost:3000/api/v1/search?q=Bosco')
req = Net::HTTP::Get.new(uri)
req['Authorization'] = "Bearer #{token}" if token

res = Net::HTTP.start(uri.hostname, uri.port) do |http|
  http.request(req)
end

puts res.body
