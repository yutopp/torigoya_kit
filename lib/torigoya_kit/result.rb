# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

require_relative 'stream_result'

module TorigoyaKit
  class TicketResultUnit
    def initialize(out="", err="", result=nil)
      @out = out
      @err = err
      @result = result
    end
    attr_accessor :out, :err, :result
  end

  class TicketResult
    def initialize(compile=nil, link=nil, run={})
      @compile = compile
      @link = link
      @run = run
    end
    attr_accessor :compile, :link, :run
  end
end # module TorigoyaKit
