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
	MessageKindTicketRequest			= 1
	MessageKindUpdateRepositoryRequest	= 2

	# Sent from server
	MessageKindOutputs					= 7
	MessageKindResult					= 8
	MessageKindSystemError				= 9
	MessageKindExit						= 10

    MessageKindSystemResult             = 11

	#
	MessageKindIndexEnd					= 11
	MessageKindInvalid					= 0xff

    #
    HeaderLength = 2 + 1 + 4 + 4

    #
    # Signature         [2]byte     //
	# MessageKind       byte        //
	# Version           [4]byte     // uint32, little endian
	# Length            [4]byte     // uint32, little endian
	# Message           []byte      // data, msgpacked
    class Packet
      Signature = "TG"

      def initialize(kind, version, data)
        if kind < MessageKindIndexBegin || kind > MessageKindIndexEnd
          raise "invalid header"
        end

        @kind = [kind].pack("C*")               # byte
        @version = [version].pack("V*")         # little endian, 32bit, unsigned int
        @message = data.to_msgpack              # msgpacked
        @length = [@message.size].pack("V*")    # little endian, 32bit, unsigned int
      end
      attr_reader :kind, :version, :message, :length

      #
      def to_binary
        return Signature + @kind + @version + @length + @message
      end
    end

    class Frame
      def initialize(kind, buffer)
        @kind = kind
        @raw_object = MessagePack.unpack(buffer)
      end
      attr_reader :kind, :raw_object

      def get_object
        case @kind
        when MessageKindOutputs
          return StreamOutputResult.from_hash(@raw_object)
        when MessageKindResult
          return StreamExecutedResult.from_hash(@raw_object)
        when MessageKindSystemError
          return StreamSystemError.new(@raw_object)
        when MessageKindExit
          return StreamExit.new(@raw_object)

        when MessageKindSystemResult
          return StreamSystemResult.new(@raw_object)
        else
          raise "Protocol :: Result kind(#{kind}) is not supported by clitnt side"
        end
      end
    end

    class InvalidFrame < RuntimeError
    end

    # ============================================================

    def self.encode(kind, version, data)
      return Packet.new(kind, version, data).to_binary
    end

    def self.decode(buffer, expected_version)
      if buffer.size >= HeaderLength
        # read signature
        signature = buffer[0...2]
        if signature != Packet::Signature
          raise InvalidFrame.new("Invalid Signature")
        end

        # read kind
        kind = buffer[2].unpack("c")[0]         # 8bit signed char

        # read version
        version = buffer[3...7].unpack("I")[0]  # 32bit unsigned int(little endian)
        if version != expected_version
          raise InvalidFrame.new("Invalid Version")
        end

        # read length
        length = buffer[7...11].unpack("I")[0]  # 32bit unsigned int(little endian)

        # read body
        if buffer.size >= HeaderLength + length
          next_buffer = buffer[(HeaderLength + length)...buffer.size]
          return Frame.new(kind, buffer[HeaderLength...(HeaderLength + length)]), next_buffer
        end
      end

      return nil, buffer
    end

  end # class Protocol
end # module TorigoyaKit
