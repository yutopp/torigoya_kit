# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

require 'msgpack'

module TorigoyaKit
  # contains source codes / inputs data
  class SourceData
    def self.make_with_compress(name, code)
      return self.new(name, code, true)
    end

    def initialize(name, code, is_compressed = false)
      @name = name
      @code = if is_compressed then
              else
                code
              end
      @is_compressed = is_compressed

      validate
    end
    attr_reader :name, :code, :is_compressed

    def to_tuple
      return [@name,
              @code,
              @is_compressed
             ]
    end

    def to_msgpack(out = '')
      return to_tuple.to_msgpack(out)
    end

    def ==(rhs)
      return @name == rhs.name &&
        @code == rhs.code
        @is_compressed == rhs.is_compressed
    end

    private
    def validate
      if @name.nil?
        @name = "*default*"
      else
        raise InvalidFormatError.new("name must be String") unless @name.is_a?(String)
      end
      raise InvalidFormatError.new("code must be String") unless @code.is_a?(String)
      raise InvalidFormatError.new("is_compressed must be Boolean") unless @is_compressed.is_a?(TrueClass) || @is_compressed.is_a?(FalseClass)
    end
  end

  #
  class Command
    def initialize(key_or_value, value=nil)
      unless value.nil?
        @key = key_or_value
        @value = value
      else
        @value = key_or_value
      end

      validate
    end
    attr_reader :key, :value

    def to_tuple
      unless @key.nil?
        return [@key, @value]
      else
        return [@value]
      end
    end

    def ==(rhs)
      return @key == rhs.key && @value == rhs.value
    end

    private
    def validate
      unless @key.nil?
        raise InvalidFormatError.new("key must be String") unless @key.is_a?(String)
      end
      raise InvalidFormatError.new("value must be String") unless @value.is_a?(String)
    end
  end

  #
  class ExecutionSetting
    def initialize(command_line, structured_command, cpu_limit, memory_limit)
      @command_line = command_line              # String
      @structured_command = structured_command  # Array!Command
      @cpu_limit = cpu_limit                    # uint64 / sec
      @memory_limit = memory_limit              # uint64 / bytes

      validate
    end
    attr_reader :command_line, :structured_command, :cpu_limit, :memory_limit

    def to_tuple
      return [@command_line,
              @structured_command.map {|x| x.to_tuple},
              @cpu_limit,
              @memory_limit
             ]
    end

    def to_msgpack(out = '')
      return to_tuple.to_msgpack(out)
    end

    def ==(rhs)
      return @command_line == rhs.command_line &&
        @structured_command == rhs.structured_command &&
        @cpu_limit == rhs.cpu_limit &&
        @memory_limit == rhs.memory_limit
    end

    private
    def validate
      unless @command_line.nil?
        raise InvalidFormatError.new("type of command_line must be String") unless @command_line.is_a?(String)
      else
        @command_line = ""
      end

      unless @structured_command.nil?
        raise InvalidFormatError.new("type of structured_command must be Array") unless @structured_command.is_a?(Array)
        @structured_command.map! do |e|
          if e.is_a?(Hash)
            raise InvalidFormatError.new("couln't convert type of element of structured_command") unless e.size == 1
            fl = e.flatten
            if fl[1].nil?
              Command.new(fl[0])
            else
              Command.new(fl[0], fl[1])
            end
          elsif e.is_a?(Array)
            raise InvalidFormatError.new("couln't convert type of element of structured_command") unless e.length == 1 || e.length == 2
            if e.length == 1
              Command.new(e[0])
            elsif e.length == 2
              Command.new(e[0], e[1])
            end
          else
            raise InvalidFormatError.new("type of element of structured_command must be Command") unless e.is_a?(Command)
            e
          end
        end
      else
        @structured_command = []
      end

      raise InvalidFormatError.new("type of cpu_limit must be Integer") unless @cpu_limit.is_a?(Integer)
      raise InvalidFormatError.new("type of memory_limit must be Integer") unless @memory_limit.is_a?(Integer)
    end
  end

  #
  class BuildInstruction
    def initialize(compile_setting, link_setting)
      @compile_setting = compile_setting    # ExecutionSetting
      @link_setting = link_setting          # ExecutionSetting

      validate
    end
    attr_reader :compile_setting, :link_setting

    def to_tuple
      return [@compile_setting.to_tuple,
              @link_setting.to_tuple
             ]
    end

    def to_msgpack(out = '')
      return to_tuple.to_msgpack(out)
    end

    def ==(rhs)
      return @compile_setting == rhs.compile_setting &&
        @link_setting == rhs.link_setting
    end

    private
    def validate()
      raise InvalidFormatError.new("type of compile_setting must be ExecutionSetting") unless @compile_setting.is_a?(ExecutionSetting)
      raise InvalidFormatError.new("type of link_setting must be ExecutionSetting") unless @link_setting.is_a?(ExecutionSetting)
    end
  end

  #
  class Input
    def initialize(stdin, run_setting)
      @stdin = stdin                # SourceData
      @run_setting = run_setting    # ExecutionSetting

      validate
    end
    attr_reader :stdin, :run_setting

    def to_tuple
      return [@stdin, @run_setting]
    end

    def to_msgpack(out = '')
      return to_tuple.to_msgpack(out)
    end

    def ==(rhs)
      return @stdin == rhs.stdin &&
        @run_settings == rhs.run_settings
    end

    private
    def validate()
      unless @stdin.nil?
        raise InvalidFormatError.new("type of stdin must be SourceData") unless @stdin.is_a?(SourceData)
      end
      raise InvalidFormatError.new("type of run_setting must be ExecutionSetting") unless @run_setting.is_a?(ExecutionSetting)
    end
  end

  #
  class RunInstruction
    def initialize(inputs)
      @inputs = inputs      # Array!Input

      validate
    end
    attr_reader :inputs

    def to_tuple
      return [@inputs.map {|x| x.to_tuple}]
    end

    def to_msgpack(out = '')
      return to_tuple.to_msgpack(out)
    end

    def ==(rhs)
      return @inputs == rhs.inputs
    end

    private
    def validate()
      raise InvalidFormatError.new("type of inputs must be Array") unless @inputs.is_a?(Array)
      @inputs.each do |e|
        raise InvalidFormatError.new("type of element of inputs must be Input") unless e.is_a?(Input)
      end
    end
  end

  #
  class Ticket
    def initialize(base_name, proc_id, proc_version, source_codes, build_inst, run_inst)
      @base_name = base_name
      @proc_id = proc_id
      @proc_version = proc_version
      @source_codes = source_codes      # Array!SourceData
      @build_inst = build_inst          # BuildInstruction
      @run_inst = run_inst              # RunInstruction

      validate
    end
    attr_reader :base_name, :proc_id, :proc_version, :source_codes, :build_inst, :run_inst

    def to_tuple
      return [@base_name,
              @proc_id,
              @proc_version,
              @source_codes.map {|x| x.to_tuple},
              @build_inst.to_tuple,
              @run_inst.to_tuple
             ]
    end

    def to_msgpack
      return to_tuple.to_msgpack()
    end

    def ==(rhs)
      return @base_name == rhs.base_name &&
        @proc_id == rhs.proc_id &&
        @proc_version == rhs.proc_version &&
        @source_codes == rhs.source_codes &&
        @build_inst == rhs.build_inst &&
        @run_inst == rhs.run_inst
    end

    private
    def validate()
      raise InvalidFormatError.new("type of base_name must be String") unless @base_name.is_a?(String)
      raise InvalidFormatError.new("type of proc_id must be Integer") unless @proc_id.is_a?(Integer)
      raise InvalidFormatError.new("type of proc_version must be String") unless @proc_version.is_a?(String)
      raise InvalidFormatError.new("type of source_codes must be Array") unless @source_codes.is_a?(Array)
      @source_codes.each do |e|
        raise InvalidFormatError.new("type of element of source_codes must be SourceData") unless e.is_a?(SourceData)
      end
      raise InvalidFormatError.new("type of build_inst must be BuildInstruction") unless @build_inst.is_a?(BuildInstruction)
      raise InvalidFormatError.new("type of run_inst must be RunInstruction") unless @run_inst.is_a?(RunInstruction)
    end
  end


  class InvalidFormatError < StandardError
    def initialize(*args)
      super(*args)
    end
  end
end # module TorigoyaKit
