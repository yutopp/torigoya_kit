# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

require 'socket'
require 'timeout'
require_relative 'ticket'
require_relative 'stream_result'
require_relative 'result'
require_relative 'protocol'

module TorigoyaClient
  class Session
    Version = "v2014/7/5"

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
      write(Protocol::MessageKindTicketRequest, ticket)
      read_stream(&block)
    end

    ########################################
    #
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

    ########################################
    #
    def reload_proc_table()
      write(Protocol::MessageKindReloadProcTableRequest)
      res = read()
      if res.is_a?(StreamSystemStatusResult)
        return
      elsif res.is_a?(StreamSystemError)
        raise res.message
      else
        raise "Unexpected error: unknown message was recieved (#{res.class})"
      end
    end

    ########################################
    #
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

    ########################################
    #
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

    ########################################
    #########################################
    private

    ########################################
    #
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

    ########################################
    #
    def read_stream(&block)
      loop do
        o = read()
        break if o.nil?

        break if o.is_a?(StreamExit)
        block.call(o) unless block.nil?
      end
    end

    ########################################
    #
    def write(kind, *args)
      expect_accepted_by_server()
      Protocol.encode_to(@socket, kind, *args)
    end

    ########################################
    #
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
