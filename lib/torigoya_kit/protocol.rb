# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

require 'msgpack'
require_relative 'stream_result'

module TorigoyaKit
  #
  class Protocol
    #
	MessageKindIndexBegin				= 0

	# Sent from client
	MessageKindAcceptRequest			= 0
	MessageKindTicketRequest			= 1
	MessageKindUpdateRepositoryRequest	= 2
    MessageKindReloadProcTableRequest	= 3
	MessageKindUpdateProcTableRequest	= 4
	MessageKindGetProcTableRequest		= 5

	# Sent from server
    MessageKindAccept                   = 6
	MessageKindOutputs					= 7
	MessageKindResult					= 8
	MessageKindSystemError				= 9
	MessageKindExit						= 10

    MessageKindSystemResult             = 11
    MessageKindProcTable                = 12

	#
	MessageKindIndexEnd					= 12
	MessageKindInvalid					= 0xff

    #
    HeaderLength = 5

    #
    class Packet
      def initialize(kind, data)
        if kind < MessageKindIndexBegin || kind > MessageKindIndexEnd
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
    def self.encode(kind, data = nil)
      return Packet.new(kind, data).to_binary
    end

    def self.encode_to(io, kind, data = nil)
      io.write(encode(kind, data))
    end

    def self.get_responses(io)
      results = []
      decode_from_stream(io) do |r|
        results << r
      end

      return results
    end

    #
    def self.decode(buffer)
      if buffer.size >= HeaderLength
        # read kind
        kind = buffer[0].unpack("c")[0]         # 8bit char

        # read length
        length = buffer[1..4].unpack("I")[0]    # 32bit unsigned int(little endian)

        if buffer.size >= HeaderLength + length
          return true, kind, length, buffer[HeaderLength...(HeaderLength + length)]
        end
      end

      return false, nil, nil, nil
    end

    def self.cat_rest(buffer, length)
      return buffer[(HeaderLength + length)..buffer.size]
    end

    #
    def self.decode_as_client(kind, decoded)
      case kind
      when MessageKindAccept
        return StreamAccept.new
      when MessageKindOutputs
        return StreamOutputResult.from_tuple(decoded)
      when MessageKindResult
        return StreamExecutedResult.from_tuple(decoded)
      when MessageKindSystemError
        return StreamSystemError.from_tuple(decoded)
      when MessageKindExit
        return StreamExit.from_tuple(decoded)

      when MessageKindSystemResult
        return StreamSystemStatusResult.new(decoded)
      when MessageKindProcTable
        return decoded
      else
        raise "Protocol :: Result kind(#{kind}) is not supported by clitnt side"
      end
    end

  end # class Protocol
end # module TorigoyaKit
