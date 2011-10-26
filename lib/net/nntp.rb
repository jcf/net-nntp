require 'socket'
require 'net/nntp/version'
require 'net/nntp/article'
require 'net/nntp/response'

module Net
  class NNTP
    NNTPException = Class.new(Exception)
    ServiceUnavailableException = Class.new(NNTPException)

    include Socket::Constants

    def initialize(server, port = 119)
      @server = server
      @port = port

      reconnect
      @socket = Socket.new(AF_INET, SOCK_STREAM, 0)

      begin
        @socket.connect(Socket.pack_sockaddr_in(port, server))
      rescue Errno::EAFNOSUPPORT
        @socket = Socket.new(AF_INET6, SOCK_STREAM, 0)
        retry
      end

      response = _response
      if response.code == 400 || response.code == 502
        raise ServiceUnavailableException.new(response_code.to_s)
      end
    end

    def close
      @socket.close
    end

    def closed?
      @socket.closed?
    end

    def reconnect
      @socket = Socket.new(AF_INET, SOCK_STREAM, 0)

      begin
        @socket.connect(Socket.pack_sockaddr_in(@port, @server))
      rescue Errno::EAFNOSUPPORT
        @socket = Socket.new(AF_INET6, SOCK_STREAM, 0)
        retry
      end

      response = _response
      if response.code == 400 || response.code == 502
        raise ServiceUnavailableException.new(response_code.to_s)
      end
    end

    def _response
      Net::NNTP::Response.parse(@socket.readline)
    end

    def read_multiline
      buffer = ""
      while true
        read = @socket.readline
        break if read.strip == "."
        buffer += read
      end

      buffer
    end

    def self.start(server, port = 119)
      obj = self.new(server, port)
      if block_given?
        yield obj
        obj.close
      end

      obj
    end

    def mode_reader
      @socket.write("MODE READER\r\n");
      _response
    end

    def listgroup(newsgroup = nil)
      @socket.write("LISTGROUP #{newsgroup}\r\n")
      response = _response

      if response.code == 211
        return read_multiline.split("\n").map {|n| n.strip.to_i}
      end

      return []
    end

    def article(message_id)
      @socket.write("ARTICLE #{message_id}\r\n")
      response = _response

      if response.code == 220
        return Net::NNTP::Article.parse(read_multiline)
      end

      false
    end

    def head(message_id)
      @socket.write("HEAD #{message_id}\r\n")
      response = _response

      if response.code == 221
        return Net::NNTP::Article.parse(read_multiline)
      end

      false
    end

    def group(newsgroup)
      @socket.write("GROUP #{newsgroup}\r\n")
      response = _response

      response.code == 211
    end

    def auth(username, password)
      @socket.write("AUTHINFO USER #{username}\r\n")
      response = _response

      if response.code == 281
        return true
      elsif response.code == 381
        @socket.write("AUTHINFO PASS #{password}\r\n")
        response = _response
        if response.code == 281
          return true
        end
      end

      false
    end
  end
end
