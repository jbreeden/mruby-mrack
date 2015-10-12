module MRack
  module Middleware; end

  @middleware = []
  @log = $stdout
  @port = 4567
  @ip = '0.0.0.0'

  class << self
    attr_accessor :log, :port, :ip
  end

  def self.run(app=nil, &block)
    unless ENV['MRACK_HANDLER']
      ENV['MRACK_HANDLER'] = 'true'
      server = TCPServer.new(@ip, @port)
      server.listen(50)
      @log.puts "MRack Server listening on #{@ip}:#{@port}"
      loop {
        MRack.accept_client(server.accept.instance_variable_get(:@apr_socket))
      }
      return
    end

    app = block if app.nil?
    @middleware.reverse.each do |mw|
      app = mw.new(app)
    end
    
    client = TCPSocket.new($socket, $pool)
    loop {
      env = { socket: client}
      result = app.call(env)
      break if result == :break
    }
  rescue Exception => ex
    @log.puts "ERROR: #{ex}"
    raise ex
  end

  def self.use(middleware)
    @middleware.push(middleware)
  end

  def self.middleware
    @middleware
  end
end
