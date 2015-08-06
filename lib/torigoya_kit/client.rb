# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

require_relative 'session'

module TorigoyaKit
  class Client
    def initialize(host, port)
      @host = host
      @port = port
      @session = new_session()
    end

    ####
    def exec_ticket(ticket)
      return @session.exec_ticket(ticket)
    end

    def exec_ticket_with_stream(ticket, &block)
      return @session.exec_ticket_with_stream(ticket, &block)
    end

    ####
    def update_packages()
      return @session.update_packages()
    end

    private
    def new_session()
      return Session.new(@host, @port)
    end
  end # class Client
end # module TorigoyaKit
