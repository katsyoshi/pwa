require "socket"
class PWA::Server
  attr_reader :tcp_server
  def initialize(host: "", port: 8080)
    @tcp_server = TCPServer.open(host, port)
  end

  def run = loop { single(tcp_server) }

  private
  def response(body)
    ["HTTP/1.1 200 OK",
     "Date: #{Time.now}",
     "Server: Apache/2.4.41 (Unix)",
     "Content-Location: index.html.en",
     "Vary: negotiate",
     "TCN: choice",
     "Last-Modified: Thu, 29 Aug 2019 05:05:59 GMT",
     "ETag: \"2d-5913a76187bc0\"",
     "Accept-Ranges: bytes",
     "Content-Length: #{body.bytesize}",
     "Keep-Alive: timeout=5, max=100",
     "Connection: Keep-Alive",
     "Content-Type: text/html",
     "",
     body].join("\r\n")
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
