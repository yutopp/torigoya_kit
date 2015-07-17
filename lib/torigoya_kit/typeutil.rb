# Copyright (c) 2015 - yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)

module TorigoyaKit
  class TypeUtil
    def self.nil_check(tag, name, elem)
      raise InvalidFormatError.new("#{tag.class}: type of `#{name}` must NOT be nil") if elem.nil?
    end

    def self.type_check(tag, name, elem, expect)
      return if elem.nil?
      raise InvalidFormatError.new("#{tag.class}: type of `#{name}` must be #{expect} (but #{elem.class})") unless elem.is_a?(expect)
    end

    def self.nonnull_type_check(tag, name, elem, expect)
      nil_check(tag, name, elem)
      type_check(tag, name, elem, expect)
    end

    def self.boolean_type_check(tag, name, elem)
      return if elem.nil?
      raise InvalidFormatError.new("#{tag.class}: type of `#{name}` must be Boolean (but #{elem.class})") unless elem.is_a?(TrueClass) || elem.is_a?(FalseClass)
    end

    def self.nonnull_boolean_type_check(tag, name, elem)
      nil_check(tag, name, elem)
      boolean_type_check(tag, name, elem)
    end

    def self.array_type_check(tag, name, elem, expect)
      return if elem.nil?
      type_check(tag, name, elem, Array)
      elem.each do |e|
        type_check(tag, "element of #{name}", e, expect)
      end
    end

    def self.nonnull_array_type_check(tag, name, elem, expect)
      nonnull_type_check(tag, name, elem, Array)
      elem.each do |e|
        nonnull_type_check(tag, "element of #{name}", e, expect)
      end
    end
  end

end # module TorigoyaKit
