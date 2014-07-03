# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

require 'msgpack'
require_relative 'stream_result'

module TorigoyaClient
  #
  class Protocol
    #
    HeaderIndexBegin    = 0

    HeaderRequest       = 0
    HeaderOutputs       = 1
    HeaderResult        = 2
    HeaderSystemError   = 3
    HeaderExit          = 4

    HeaderIndexEnd      = 4

    HeaderInvalid       = 0xff

    #
    HeaderLength = 5

    #
    class Packet
      def initialize(kind, data)
        if kind < HeaderIndexBegin || kind > HeaderIndexEnd
          raise "invalid header"
        end

        @kind = [kind].pack("C*")
        @encoded_data = data.to_msgpack
        @size = [@encoded_data.size].pack("V*")
      end
      attr_reader :kind, :size, :encoded_data

      #
      def to_binary
        return @kind + @size + @encoded_data
      end
    end

    #
    def self.encode(kind, data)
      return Packet.new(kind, data).to_binary
    end

    #
    def self.decode_from_stream(io, &block)
      buffer = ""
      accepted = false

      loop do
        b = io.readpartial(1024)
        buffer << b

        if buffer.size < HeaderLength
          continue
        end

        #
        kind = buffer[0].unpack("c")[0]         # 8bit char

        #
        length = buffer[1..4].unpack("I")[0]    # 32bit unsigned int

        #
        if buffer.size >= HeaderLength + length
          content = buffer[HeaderLength...(HeaderLength + length)]

          #
          o = Protocol.decode(kind, MessagePack.unpack(content))
          if o.is_a?(StreamExit) then accepted = true end
          block.call(o) unless block.nil?

          # assign rest
          buffer = buffer[(HeaderLength + length)..buffer.size]
        end

      end

    rescue EOFError
      # puts "EOF"

    ensure
      return accepted
    end

    #
    def self.decode(kind, decoded)
      case kind
      when HeaderRequest
        raise "Request message was not suppored in client"
      when HeaderOutputs
        return StreamOutputResult.from_tuple(decoded)
      when HeaderResult
        return StreamExecutedResult.from_tuple(decoded)
      when HeaderSystemError
        return StreamSystemError.from_tuple(decoded)
      when HeaderExit
        return StreamExit.from_tuple(decoded)
      end
    end

  end # class Protocol
end # module TorigoyaClient
