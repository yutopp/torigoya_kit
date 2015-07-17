# Copyright (c) 2014 - 2015 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

require 'msgpack'
require_relative 'typeutil'

module TorigoyaKit
  # contains source codes / inputs data
  class SourceData
    def self.make_with_compress(name, code)
      return self.new(name, code, true)
    end

    def initialize(name, code, is_compressed = false)
      @name = name
      @data = if is_compressed then
                # NOT: implemented
              else
                code
              end
      @is_compressed = is_compressed

      validate
    end
    attr_reader :name, :data, :is_compressed

    def to_hash
      return {
        name: @name,
        data: @data,
        is_compressed: @is_compressed,
      }
    end

    def to_msgpack(out = '')
      return to_hash.to_msgpack(out)
    end

    def ==(rhs)
      return @name == rhs.name &&
        @data == rhs.data
        @is_compressed == rhs.is_compressed
    end

    private
    def validate
      if @name.nil?
        @name = "*default*"
      else
        TypeUtil.nonnull_type_check(self, "name", @name, String)
      end
      TypeUtil.nonnull_type_check(self, "data", @data, String)
      TypeUtil.nonnull_boolean_type_check(self, "is_compressed", @is_compressed)
    end
  end

  #
  class ExecutionSetting
    def initialize(args, envs, cpu_limit, memory_limit)
      @args = args                  # Array!String
      @envs = envs                  # Array!String
      @cpu_limit = cpu_limit        # uint64 / sec
      @memory_limit = memory_limit  # uint64 / bytes

      validate
    end
    attr_reader :args, :envs, :cpu_limit, :memory_limit

    def to_hash
      return {
        args: @args,
        envs: @envs,
        cpu_time_limit: @cpu_limit,
        memory_bytes_limit: @memory_limit
      }
    end

    def to_msgpack(out = '')
      return to_hash.to_msgpack(out)
    end

    def ==(rhs)
      return @args == rhs.args &&
        @envs == rhs.envs &&
        @cpu_limit == rhs.cpu_limit &&
        @memory_limit == rhs.memory_limit
    end

    private
    def validate
      TypeUtil.nonnull_array_type_check(self, "args", @args, String)
      TypeUtil.nonnull_array_type_check(self, "envs", @envs, String)
      TypeUtil.nonnull_type_check(self, "cpu_limit", @cpu_limit, Integer)
      TypeUtil.nonnull_type_check(self, "memory_limit", @memory_limit, Integer)
    end
  end

  #
  class BuildInstruction
    def initialize(compile_setting, link_setting)
      @compile_setting = compile_setting    # ExecutionSetting
      @link_setting = link_setting          # ExecutionSetting?

      validate
    end
    attr_reader :compile_setting, :link_setting

    def to_hash
      return {
        compile_setting: @compile_setting.to_hash,
        link_setting: unless @link_setting.nil? then @link_setting.to_hash else nil end
      }
    end

    def to_msgpack(out = '')
      return to_hash.to_msgpack(out)
    end

    def ==(rhs)
      return @compile_setting == rhs.compile_setting &&
        @link_setting == rhs.link_setting
    end

    private
    def validate()
      TypeUtil.nonnull_type_check(self, "compile_setting", @compile_setting, ExecutionSetting)
      TypeUtil.type_check(self, "link_setting", @link_setting, ExecutionSetting)
    end
  end

  #
  class Input
    def initialize(stdin, run_setting)
      @stdin = stdin                # SourceData?
      @run_setting = run_setting    # ExecutionSetting

      validate
    end
    attr_reader :stdin, :run_setting

    def to_hash
      return {
        stdin: @stdin,
        run_setting: @run_setting.to_hash
      }
    end

    def to_msgpack(out = '')
      return to_hash.to_msgpack(out)
    end

    def ==(rhs)
      return @stdin == rhs.stdin &&
        @run_settings == rhs.run_settings
    end

    private
    def validate()
      TypeUtil.type_check(self, "stdin", @stdin, SourceData)
      TypeUtil.nonnull_type_check(self, "run_setting", @run_setting, ExecutionSetting)
    end
  end

  #
  class RunInstruction
    def initialize(inputs)
      @inputs = inputs      # Array!Input

      validate
    end
    attr_reader :inputs

    def to_hash
      return [@inputs.map {|x| x.to_hash}]
    end

    def to_msgpack(out = '')
      return to_hash.to_msgpack(out)
    end

    def ==(rhs)
      return @inputs == rhs.inputs
    end

    private
    def validate()
      TypeUtil.nonnull_array_type_check(self, "inputs", @inputs, Input)
    end
  end

  #
  class Ticket
    def initialize(base_name, source_codes, build_inst, run_inst)
      @base_name = base_name            # String
      @source_codes = source_codes      # Array!SourceData
      @build_inst = build_inst          # BuildInstruction?
      @run_inst = run_inst              # RunInstruction?

      validate
    end
    attr_reader :base_name, :source_codes, :build_inst, :run_inst

    def to_hash
      return {
        base_inst: @base_name,
        sources: @source_codes.map {|x| x.to_hash},
        build_inst: unless @build_inst.nil? then @build_inst.to_hash else nil end,
        run_inst: unless @run_inst.nil? then @run_inst.to_hash else nil end,
      }
    end

    def to_msgpack
      return to_hash.to_msgpack()
    end

    def ==(rhs)
      return @base_name == rhs.base_name &&
        @source_codes == rhs.source_codes &&
        @build_inst == rhs.build_inst &&
        @run_inst == rhs.run_inst
    end

    private
    def validate()
      TypeUtil.nonnull_type_check(self, "base_name", @base_name, String)
      TypeUtil.nonnull_array_type_check(self, "source_codes", @source_codes, SourceData)
      TypeUtil.type_check(self, "build_inst", @build_inst, BuildInstruction)
      TypeUtil.type_check(self, "run_inst", @run_inst, RunInstruction)
    end
  end


  class InvalidFormatError < StandardError
    def initialize(*args)
      super(*args)
    end
  end

end # module TorigoyaKit
