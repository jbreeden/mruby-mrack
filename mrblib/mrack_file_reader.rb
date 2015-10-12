module MRack
module Middleware
class FileReader
  class FileReaderImpl
    def initialize(file)
      @file = file
    end

    def each
      return self.enum_for(:each) unless block_given?
      while chunk = @file.read(1000)
        yield chunk
      end
    end
  end

  def initialize(app)
    @app = app
  end

  def call(env)
    resp = @app.call(env)
    content = resp[2]
    resp[2] = FileReaderImpl.new(content) if content.kind_of?(File)
    resp
  end
end
end
end
