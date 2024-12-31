require "socket"
require "pf2"
class PWA::Server
  attr_reader :tcp_server
  def initialize(host: "", port: 8080)
    @tcp_server = TCPServer.open(host, port)
  end

  def profile(&block)
    Pf2.start(threads: :all)
    yield self
    profile = Pf2.stop
    File.write("#{Time.now.to_i}_#{profile.__id__}.txt", profile)
  end

  def run
    trap(:INT) do
      puts "STOP"
      return
    end
    loop do
      single(tcp_server)
    end
  end

  private
  def response(body)
    "HTTP/1.1 200 OK\r\nDate: #{Time.now}\r\nServer: Apache/2.4.41 (Unix)\r\nContent-Location: index.html.en\r\nVary: negotiate\r\nTCN: choice\r\nLast-Modified: Thu, 29 Aug 2019 05:05:59 GMT\r\nETag: \"2d-5913a76187bc0\"\r\nAccept-Ranges: bytes\r\nContent-Length: #{body.bytesize}\r\nKeep-Alive: timeout=5, max=100\r\nConnection: Keep-Alive\r\nContent-Type: text/html\r\n\r\n#{body}"
  end

  def single(socket)
    socket.accept.then do
      it.sendmsg(response("<http><body><h1>hello</h1></body></html>"))
      it.close
    end
  end

  def threads(socket, &block)
    Thread.start(socket.accept) do
      it.sendmsg(response("<http><body><h1>hello</h1></body></html>"))
      it.close
    end
  end
end
