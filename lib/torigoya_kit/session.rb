# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

require 'socket'
require 'timeout'
require_relative 'ticket'
require_relative 'stream_result'
require_relative 'result'
require_relative 'protocol'

module TorigoyaKit
  class Session
    Version = 20150715

    ########################################
    #
    def initialize(host, port)
      # 5 sec
      timeout(5) do
        @socket = Socket.tcp(host, port)
      end

      @buffer = ""
    end

    ########################################
    #
    def exec_ticket(ticket)
      result = TicketResult.new
      exec_ticket_with_stream(ticket) do |res|
        if res.is_a?(StreamOutputResult) || res.is_a?(StreamExecutedResult)
          case res.mode
          when ResultMode::CompileMode
            result.compile = TicketResultUnit.new if result.compile.nil?
          when ResultMode::LinkMode
            result.link = TicketResultUnit.new if result.link.nil?
          when ResultMode::RunMode
            result.run[res.index] = TicketResultUnit.new if result.run[res.index].nil?
          end

          if res.is_a?(StreamOutputResult)
            case res.output.fd
            when StreamOutput::StdoutFd
              case res.mode
              when ResultMode::CompileMode
                result.compile.out << res.output.buffer
              when ResultMode::LinkMode
                result.link.out << res.output.buffer
              when ResultMode::RunMode
                result.run[res.index].out << res.output.buffer
              end
            when StreamOutput::StderrFd
              case res.mode
              when ResultMode::CompileMode
                result.compile.err << res.output.buffer
              when ResultMode::LinkMode
                result.link.err << res.output.buffer
              when ResultMode::RunMode
                result.run[res.index].err << res.output.buffer
              end
            end

          elsif res.is_a?(StreamExecutedResult)
            case res.mode
            when ResultMode::CompileMode
              result.compile.result = res.result
            when ResultMode::LinkMode
              result.link.result = res.result
            when ResultMode::RunMode
              result.run[res.index].result = res.result
            end
          end

        elsif res.is_a?(StreamSystemError)
          raise res.message
        else
          raise "Unexpected error: unknown message was recieved (#{res.class})"
        end
      end
      return result
    end

    ########################################
    #
    def exec_ticket_with_stream(ticket, &block)
      send(Protocol::MessageKindTicketRequest, ticket)

      recv_stream(&block)
    end

    ########################################
    #
    def update_packages()
      send(Protocol::MessageKindUpdateRepositoryRequest, nil)

      recv_stream() do |res|
        if res.is_a?(StreamSystemResult)
          return res.status
        elsif res.is_a?(StreamSystemError)
          raise res.message
        else
          raise "Unexpected error: unknown message was recieved (#{res.class})"
        end
      end
    end

    ########################################
    private

    ########################################
    #
    def recv_frame_object()
      is_closed = false

      loop do
        begin
          @buffer << @socket.readpartial(8096)
        rescue EOFError
          is_closed = true
        end

        frame, @buffer = Protocol.decode(@buffer, Version)
        if frame.nil?
          if is_closed
            break   # finish loop
          else
            next    # try to read data
          end
        end

        return frame.get_object()
      end # loop

      return nil
    end

    ########################################
    #
    def recv_stream(&block)
      loop do
        obj = recv_frame_object()
        raise "object is empty" if obj.nil?

        break if obj.is_a?(StreamExit)
        block.call(obj) unless block.nil?
      end
    end

    ########################################
    #
    def send(kind, args)
      @socket.write(Protocol.encode(kind, Version, args))
    end

  end # class Session
end # module TorigoyaKit
