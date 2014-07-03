# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

require 'socket'
require 'timeout'
require_relative 'ticket'
require_relative 'stream_result'
require_relative 'protocol'

module TorigoyaClient
  #
  class Client
    def initialize(host, port)
      # 5 sec
      timeout(5) do
        @socket = Socket.tcp(host, port)
      end
    end

    def write_request(data)
      @socket.write(Protocol.encode(Protocol::HeaderRequest, data))
    end

    def recieveing()
      Protocol.decode_from_stream(@socket) do |message|
        puts message
      end
    end

  end # class Client
end # module TorigoyaClient
