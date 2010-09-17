module Wikimate
  class Server

    def initialize(root, options={})
      @root = root
      @options = options
    end

    def port
      @options['port'] || 3456
    end

    def handler
      @handler ||= Rack::Handler.get('webrick')
    end

    def run
      handler.run self, :Host => 'localhost', :Port => port do |server|
        trap(:INT) do
          ## Use thins' hard #stop! if available, otherwise just #stop
          server.respond_to?(:stop!) ? server.stop! : server.stop
        end
      end
    end

    def interpreter
      @interpreter ||= Interpreter.new(@root, @options.merge("edit_links" => true))
    end

    def call(env)
      path_info = env["PATH_INFO"]
      if path_info == "/"
        if interpreter.pages.include? 'Index'
          path_info = "/Index"
        else
          path_info = "/AllPages"
        end
      end
      if page = interpreter.pages.detect{|p| "/#{p}" == path_info.sub(/\.html$/,'')}
        content = interpreter.html_for_page(page)
        [200, {"Content-Type" => "text/html", "Content-Length" => content.length.to_s}, content]
      elsif path_info == "/application.js"
        content = File.open('application.js').read
        [200, {"Content-Type" => "text/javascript", "Content-Length" => content.length.to_s}, content]
      elsif path_info == "/application.css"
        content = File.open('application.css').read
        [200, {"Content-Type" => "text/css", "Content-Length" => content.length.to_s}, content]      
      else
        [404, {"Content-Type" => "text/plain"}, "not found"]
      end
    end

  end
end