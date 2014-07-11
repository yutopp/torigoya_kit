# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

require_relative 'session'

module TorigoyaKit
  class Client
    def initialize(host, port)
      @host = host
      @port = port
    end

    ####
    def exec_ticket(ticket)
      return get_session().exec_ticket(ticket)
    end

    def exec_ticket_with_stream(ticket, &block)
      return get_session().exec_ticket_with_stream(ticket, &block)
    end

    ####
    def update_packages()
      return get_session().update_packages()
    end

    ####
    def reload_proc_table()
      return get_session().reload_proc_table()
    end

    def update_proc_table()
      return get_session().update_proc_table()
    end

    def get_proc_table()
      return get_session().get_proc_table()
    end

    private
    def get_session()
      return Session.new(@host, @port)
    end
  end # class Client
end # module TorigoyaKit
