# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

require 'socket'
require 'timeout'
require_relative 'ticket'
require_relative 'stream_result'
require_relative 'protocol'

module TorigoyaClient
  class Session
    Version = "v2014/7/5"

    def initialize(host, port)
      # 5 sec
      timeout(5) do
        @socket = Socket.tcp(host, port)
      end

      @buffer = ""
    end

    def read()
      accepted = false
      is_closed = false

      loop do
        begin
          @buffer << @socket.readpartial(1024)
        rescue EOFError
          is_closed = true
        end

        is_recieved, kind, length, content = Protocol.decode(@buffer)
        unless is_recieved
          if is_closed
            break
          else
            next
          end
        end

        # set rest
        @buffer = Protocol.cat_rest(@buffer, length)

        return Protocol.decode_as_client(kind, MessagePack.unpack(content))
      end # loop

      return nil
    end

    def read_stream(&block)
      loop do
        o = read()
        break if o.nil?

        block.call(o) unless block.nil?
        break if o.is_a?(StreamExit)
      end
    end



    def recieveing()
      read_stream do |message|
        puts message
      end
    end

    def recieve()
    end

    def write(kind, *args)
      expect_accepted_by_server()
      Protocol.encode_to(@socket, kind, *args)
    end

    def exec_ticket(ticket)
      write(Protocol::MessageKindTicketRequest, ticket)
    end

    def update_packages()
      write(Protocol::MessageKindUpdateRepositoryRequest)
      res = read()
      if res.is_a?(StreamSystemStatusResult)
        return
      elsif res.is_a?(StreamSystemError)
        raise res.message
      else
        raise "Unexpected error: unknown message was recieved (#{res.class})"
      end
    end

    def update_proc_table()
      write(Protocol::MessageKindUpdateProcTableRequest)
      res = read()
      if res.is_a?(StreamSystemStatusResult)
        return
      elsif res.is_a?(StreamSystemError)
        raise res.message
      else
        raise "Unexpected error: unknown message was recieved (#{res.class})"
      end
    end

    def get_proc_table()
      write(Protocol::MessageKindGetProcTableRequest)
      res = read()
      if res.is_a?(Hash)
        return res
      elsif res.is_a?(StreamSystemError)
        raise res.message
      else
        raise "Unexpected error: unknown message was recieved (#{res.class})"
      end
    end

    private
    def expect_accepted_by_server
      Protocol.encode_to(@socket, Protocol::MessageKindAcceptRequest, Version)
      res = read()
      if res.is_a?(StreamAccept)
        return
      elsif res.is_a?(StreamSystemError)
        raise res.message
      else
        raise "Unexpected error: unknown message was recieved"
      end
    end
  end # class Session
end # module TorigoyaClient
