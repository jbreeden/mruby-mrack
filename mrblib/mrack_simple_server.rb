module MRack
module Middleware
class SimpleServer
  def initialize(app)
    @client_id = rand(999999) + Time.now.usec
    MRack.log.puts "[SimpleServer] INFO: Client connected (Client ID: #{@client_id})"
    @app = app
  end

  def call(env)
    socket = env[:socket]

    # Parse request
    MRack.log.puts "[SimpleServer] INFO: Parsing Request"
    request_line = socket.gets
    if request_line.nil?
      MRack.log.puts "[SimpleServer] INFO: Client disconnected (Client ID: #{@client_id})"
      return :break
    end
    request_line_tokens = request_line.split(' ')
    env[:client_id] = @client_id
    env[:method] = request_line_tokens[0]
    env[:path] = request_line_tokens[1]
    env[:http_version] = request_line_tokens[2]
    env[:headers] = headers = {}
    until (line = socket.gets.strip) == ''
      tokens = line.split(':')
      headers[tokens[0]] = line[(tokens[0].length + 1)..-1].strip
    end
    if env[:headers]["Content-Length"]
      env[:content] = socket.read(env[:headers]["Content-Length"].to_i)
    else
      env[:content] = nil
    end

    # Invoke next app
    resp = @app.call(env)

    # Send response
    MRack.log.puts "[SimpleServer] INFO: Writing Response"
    if resp.nil?
      MRack.log.puts "[SimpleServer] WARNING: Nil response from app"
      return
    end
    if resp[2] == '' && !resp[1]["Content-Length"]
      resp[1]["Content-Length"] = 0
    end
    socket.write("#{env[:http_version]} #{resp[0]} #{resp[0]}\r\n")
    resp[1].each do |key, value|
      socket.write("#{key}: #{value}\r\n")
    end
    socket.write("\r\n")
    resp[2] = [resp[2]] if resp[2].kind_of?(String)
    resp[2].each do |chunk|
      socket.write(chunk)
    end
    nil
  end
end
end
end
