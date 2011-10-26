require 'socket'
require 'net/nntp/version'
require 'net/nntp/article'
require 'net/nntp/response'

module Net
  class NNTP
    NNTPException = Class.new(Exception)
    ServiceUnavailableException = Class.new(NNTPException)

    include Socket::Constants

    attr_reader :response

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

      response = Net::NNTP::Response.parse(@socket.readline)

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

      response = Net::NNTP::Response.parse(@socket.readline)

      if response.code == 400 || response.code == 502
        raise ServiceUnavailableException.new(response_code.to_s)
      end
    end

    def read_multiline(limit = nil)
      lines, buffer = 0, ""
      while true
        read = @socket.readline
        lines += 1
        break if lines == limit || read.strip == '.'
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
      ask('MODE READER')
    end

    def listgroup(newsgroup = nil, limit = nil)
      ask("LISTGROUP #{newsgroup}")

      if response.code == 211
        return read_multiline(limit).split("\n").map {|n| n.strip.to_i}
      end

      return []
    end

    def article(message_id)
      ask("ARTICLE #{message_id}")

      if response.code == 220
        return Net::NNTP::Article.parse(read_multiline)
      end

      false
    end

    def head(message_id)
      ask("HEAD #{message_id}")

      if response.code == 221
        return Net::NNTP::Article.parse(read_multiline)
      end

      false
    end

    def group(newsgroup)
      ask("GROUP #{newsgroup}")
      response.code == 211
    end

    def auth(username, password)
      ask("AUTHINFO USER #{username}")

      if response.code == 281
        return true
      elsif response.code == 381
        ask("AUTHINFO PASS #{password}")
        if response.code == 281
          return true
        end
      end

      false
    end

    private

    def ask(message)
      @socket.write("#{message}\r\n")
      @response = Net::NNTP::Response.parse(@socket.readline)
    end
  end
end
