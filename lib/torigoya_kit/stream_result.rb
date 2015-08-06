# Copyright (c) 2014 - 2015 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

require_relative 'typeutil'

module TorigoyaKit
  class ResultMode
    CompileMode = 0
    LinkMode    = 1
    RunMode     = 2
  end

  #
  class StreamOutput
    StdoutFd    = 1
    StderrFd    = 2

    def initialize(fd, buffer)
      @fd = fd
      @buffer = buffer

      validate
    end
    attr_reader :fd, :buffer

    def self.from_hash(hash)
      return StreamOutput.new(hash["fd"], hash["buffer"])
    end

    def to_s
      return "#{self.class}/[#{@fd} #{@buffer}]"
    end

    private
    def validate()
      TypeUtil.nonnull_type_check(self, "fd", @fd, Integer)
      TypeUtil.nonnull_type_check(self, "buffer", @buffer, String)
    end
  end

  # related to MessageKindOutputs
  class StreamOutputResult
    def initialize(mode, index, output)
      @mode = mode
      @index = index
      @output = output

      validate
    end
    attr_reader :mode, :index, :output

    def self.from_hash(hash)
      return StreamOutputResult.new(
               hash["mode"],
               hash["index"],
               StreamOutput.from_hash(hash["output"])
             )
    end

    def to_s
      return "#{self.class}/[#{@mode} #{@index} #{@output.to_s}]"
    end

    private
    def validate()
      TypeUtil.nonnull_type_check(self, "mode", @mode, Integer)
      TypeUtil.nonnull_type_check(self, "index", @index, Integer)
      TypeUtil.nonnull_type_check(self, "output", @output, StreamOutput)
    end
  end

  #
  class ExecutedResult
    def initialize(exited, exit_status, signaled, signal, cpu_time, memory, s_es, s_em)
      @exited = exited
      @exit_status = exit_status
      @signaled = signaled
      @signal = signal

      @used_cpu_time_sec = cpu_time
      @used_memory_bytes = memory

      @system_error_status = s_es
      @system_error_message = s_em

      validate
    end
    attr_reader :exited, :exit_status, :signaled, :signal
    attr_reader :used_cpu_time_sec, :used_memory_bytes
    attr_reader :system_error_status, :system_error_message

    def self.from_hash(hash)
      return ExecutedResult.new(
               hash["exited"],
               hash["exit_status"],
               hash["signaled"],
               hash["signal"],
               hash["used_cpu_time_sec"],
               hash["used_memory_bytes"],
               hash["system_error_status"],
               hash["system_error_message"],
             )
    end

    private
    def validate()
      TypeUtil.nonnull_boolean_type_check(self, "exited", @exited)
      TypeUtil.nonnull_type_check(self, "exit_status", @exit_status, Integer)
      TypeUtil.nonnull_boolean_type_check(self, "signaled", @signaled)
      TypeUtil.nonnull_type_check(self, "signal", @signal, Integer)

      TypeUtil.nonnull_type_check(self, "used_cpu_time_sec", @used_cpu_time_sec, Float)
      TypeUtil.nonnull_type_check(self, "used_memory_bytes", @used_memory_bytes, Integer)

      TypeUtil.nonnull_type_check(self, "system_error_status", @system_error_status, Integer)
      TypeUtil.nonnull_type_check(self, "system_error_message", @system_error_message, String)
    end
  end

  # related to StreamExecutedResult
  class StreamExecutedResult
    def initialize(mode, index, result)
      @mode = mode
      @index = index
      @result = result

      validate
    end
    attr_reader :mode, :index, :result

    def self.from_hash(hash)
      return StreamExecutedResult.new(
               hash["mode"],
               hash["index"],
               ExecutedResult.from_hash(hash["result"])
             )
    end

    def to_s
      return "#{self.class}/[#{@mode} #{@index} #{@result.to_s}]"
    end

    private
    def validate()
      TypeUtil.nonnull_type_check(self, "mode", @mode, Integer)
      TypeUtil.nonnull_type_check(self, "index", @index, Integer)
      TypeUtil.nonnull_type_check(self, "result", @result, ExecutedResult)
    end
  end

  # related to MessageKindSystemError
  class StreamSystemError
    def initialize(message)
      @message = message

      validate
    end
    attr_reader :message

    def to_s
      return "#{self.class}/[#{@message}]"
    end

    private
    def validate()
      TypeUtil.nonnull_type_check(self, "message", @message, String)
    end
  end

  # related to MessageKindExit
  class StreamExit
    def initialize(message)
      @message = message

      validate
    end
    attr_reader :message

    def to_s
      return "#{self.class}/[#{@message}]"
    end

    private
    def validate()
      TypeUtil.nonnull_type_check(self, "message", @message, String)
    end
  end

  #
  class StreamSystemResult
    def initialize(status)
      @status = status
    end
    attr_reader :status
  end
end # module TorigoyaKit
