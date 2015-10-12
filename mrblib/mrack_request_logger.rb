module MRack
module Middleware
class RequestLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    MRack.log.puts "[RequestLogger] REQUEST (Client ID: #{env[:client_id]})"
    puts "#{env[:method]} #{env[:path]} #{env[:http_version]}"
    env[:headers].each do |key, value|
      MRack.log.puts "#{key}: #{value}"
    end
    resp = @app.call(env)
    MRack.log.puts "[RequestLogger] RESPONSE (Client ID: #{env[:client_id]})"
    MRack.log.puts "#{env[:http_version]} #{resp[0]}"
    resp[1].each do |key, value|
      MRack.log.puts "#{key}: #{value}"
    end
    resp
  rescue Exception => ex
    MRack.log.puts "[RequestLogger] ERROR: Exception calling app from logger: #{ex}"
    raise ex
  end
end
end
end
