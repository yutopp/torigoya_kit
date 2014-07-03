# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

require 'msgpack'

module TorigoyaClient
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
    end
    attr_reader :name, :code

    def to_tuple
      return [@name,
              @code,
              @is_compressed
             ]
    end

    def to_msgpack(out = '')
      return to_tuple.to_msgpack(out)
    end
  end

  #
  class ExecutionSetting
    def initialize(command_line, structured_command, cpu_limit, memory_limit)
      @command_line = command_line              # String
      @structured_command = structured_command  # Array!(Array!String)
      @cpu_limit = cpu_limit                    # uint64 / sec
      @memory_limit = memory_limit              # uint64 / bytes
    end

    def to_tuple
      return [@command_line,
              @structured_command,
              @cpu_limit,
              @memory_limit
             ]
    end

    def to_msgpack(out = '')
      return to_tuple.to_msgpack(out)
    end
  end

  #
  class BuildInstruction
    def initialize(compile_setting, link_setting)
      @compile_setting = compile_setting    # ExecutionSetting
      @link_setting = link_setting          # ExecutionSetting
    end

    def to_tuple
      return [@compile_setting.to_tuple,
              @link_setting.to_tuple
             ]
    end

    def to_msgpack(out = '')
      return to_tuple.to_msgpack(out)
    end
  end

  #
  class Input
    def initialize(stdin, run_setting)
      @stdin = stdin                # SourceData
      @run_setting = run_setting    # ExecutionSetting
    end

    def to_tuple
      return [@stdin, @run_setting]
    end

    def to_msgpack(out = '')
      return to_tuple.to_msgpack(out)
    end
  end

  #
  class RunInstruction
    def initialize(inputs)
      @inputs = inputs      # Array!Input
    end

    def to_tuple
      return [@inputs.map {|x| x.to_tuple}]
    end

    def to_msgpack(out = '')
      return to_tuple.to_msgpack(out)
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
    end

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
  end

end # module TorigoyaClient
