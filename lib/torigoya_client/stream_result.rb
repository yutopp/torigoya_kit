# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

module TorigoyaClient
  #
  class StreamOutput
    StdoutFd = 0
    StderrFd = 1

    def initialize(fd, buffer)
      @fd = fd
      @buffer = buffer
    end
    attr_reader :fd, :buffer

    def self.from_tuple(tupled)
      raise "type error [expected Array but #{message.class}] :: #{self}" unless tupled.is_a?(Array)
      raise "invalid format(tuple size is different [expected 2 but #{tupled.size}] :: #{self})" unless tupled.size == 2

      return StreamOutput.new(tupled[0], tupled[1])
    end

    def to_s
      return "#{self.class}/[#{@fd} #{@buffer}]"
    end
  end

  #
  class StreamOutputResult
    def initialize(mode, index, output)
      @mode = mode
      @index = index
      @output = output
    end
    attr_reader :mode, :index, :output

    def self.from_tuple(tupled)
      raise "type error [expected Array but #{message.class}] :: #{self}" unless tupled.is_a?(Array)
      raise "invalid format(tuple size is different [expected 3 but #{tupled.size}] :: #{self})" unless tupled.size == 3

      return StreamOutputResult.new(tupled[0],
                                    tupled[1],
                                    StreamOutput.from_tuple(tupled[2])
                                    )
    end

    def to_s
      return "#{self.class}/[#{@mode} #{@index} #{@output.to_s}]"
    end
  end

  #
  class ExecutedResult
    def initialize(cpu_time, memory, signal, return_code, command_line, status, error_message)
      @used_cpu_time_sec = cpu_time
      @used_memory_bytes = memory
      @signal = signal
      @return_code = return_code
      @command_line = command_line
      @status = status
      @system_error_message = error_message
    end
    attr_reader :used_cpu_time_sec, :used_memory_bytes, :signal, :return_code, :command_line, :status, :system_error_message

    def self.from_tuple(tupled)
      raise "type error [expected Array but #{message.class}] :: #{self}" unless tupled.is_a?(Array)
      raise "invalid format(tuple size is different [expected 7 but #{tupled.size}] :: #{self})" unless tupled.size == 7

      return ExecutedResult.new(tupled[0],
                                tupled[1],
                                tupled[2],
                                tupled[3],
                                tupled[4],
                                tupled[5],
                                tupled[6]
                                )
    end

    def to_s
      return "#{self.class}/[#{@used_cpu_time_sec} #{@used_memory_bytes} #{@signal} #{@return_code} #{@command_line} #{@status} #{@system_error_message}]"
    end
  end

  #
  class StreamExecutedResult
    def initialize(mode, index, result)
      @mode = mode
      @index = index
      @result = result
    end
    attr_reader :mode, :index, :result

    def self.from_tuple(tupled)
      raise "type error [expected Array but #{message.class}] :: #{self}" unless tupled.is_a?(Array)
      raise "invalid format(tuple size is different [expected 3 but #{tupled.size}] :: #{self})" unless tupled.size == 3

      return StreamExecutedResult.new(tupled[0],
                                      tupled[1],
                                      ExecutedResult.from_tuple(tupled[2])
                                      )
    end

    def to_s
      return "#{self.class}/[#{@mode} #{@index} #{@result.to_s}]"
    end
  end

  #
  class StreamExit
    def initialize(message)
      @message = message
    end
    attr_reader :message

    def self.from_tuple(message)
      raise "type error [expected String but #{message.class}] :: #{self}" unless message.is_a?(String)

      return StreamExit.new(message)
    end

    def to_s
      return "#{self.class}/[#{@message}]"
    end
  end

  #
  class StreamSystemError
    def initialize(message)
      @message = message
    end
    attr_reader :message

    def self.from_tuple(message)
      raise "type error [expected String but #{message.class}] :: #{self}" unless message.is_a?(String)

      return StreamSystemError.new(message)
    end

    def to_s
      return "#{self.class}/[#{@message}]"
    end
  end

end # module TorigoyaClient
