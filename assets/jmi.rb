module Jmi
  module Generics
  end
  module J
    class Void
    end
    class Boolean
    end
    class Int
    end
    class Long
      def initialize(lo, hi = 0)
        @lo, @hi = lo, hi
      end
      attr_reader :lo, :hi
    end
    class Float
    end
    def class_path(klass, sep = "/")
      path = klass.instance_variable_get "@class_path"
      return path if path

      until (path = klass.to_s).index("Jmi::J::") == 0
        klass = klass.superclass
        raise "#{self} is not Java class/interface" unless klass
      end
      path = path[8..-1].split("::")

      current = Jmi::J
      path[0, path.length - 1].each do |s|
        current = current.const_get s
        if current.is_a? Class
          s.replace s + "$"
        else
          s.downcase!
          s.replace s + sep
        end
      end
      path.join("")
    end
    SIG_TABLE = {
      Void => "V",
      Boolean => "Z",
      Int => "I",
      Long => "J",
      Float => "F",
      Generics => "Ljava/lang/Object;"
    }
    SIG_TABLE.extend self
    SIG_TABLE.default_proc = lambda do |h, k|
      h[k] = "L#{SIG_TABLE.class_path(k)};"
    end
    TYPE_TABLE = {
    }
    def class2item(klass, table)
      prefix = ""
      while klass.is_a? Array
        klass = klass.first
        prefix += "["
      end
      item = table[klass]
      return nil unless item
      prefix + item
    end
    def class2sig(klass)
      class2item(klass, SIG_TABLE)
    end
    def class2type(klass)
      if klass == Generics
        if @iclass
          klass = @iclass
        else
          klass = self
        end
      end
      class2item(klass, TYPE_TABLE) || class2sig(klass)
    end
    def get_sig(ret, args)
      ret = class2sig(ret)
      "(#{args.map{|a|class2sig(a)}.join("")})#{ret}"
    end
    def get_type(args)
      args.map{|a|class2type(a)}.join("")
    end
    NAME_TABLE = {
      "void" => Void,
      "boolean" => Boolean,
      "int" => Int,
      "long" => Long,
      "float" => Float
    }
    def name2class(name)
      NAME_TABLE[name]
    end
    def proc_method(name, methods)
      lambda do |*args|
        found = false
        ret = nil
        methods.each do |meth|
          if meth.setup args
            found = true
            ret = meth.call self
            break
          end
        end
        if found
          ret
        else
          recv = self.is_a?(::Class) ? "#{self}." : "#{self.class}#"
          raise "mismatching #{recv}#{name}(#{args.map{|a|a.inspect}.join(', ')})"
        end
      end
    end
  end
  module Definition
    include J
    attr_reader :method_table
    def attach_init(*args)
      @method_table[nil] ||= []
      @method_table[nil].push Jmi::Method.new self, Void, "<init>", args
    end
    def attach(ret, name, *args)
      attach_at self, ret, name, *args
    end
    def attach_static(ret, name, *args)
      attach_at singleton_class, ret, name, *args
    end
    def attach_const(ret, name)
      val = Jmi.get_field_static self, ret, name
      const_set name.upcase, val
    end
    def attach_at(klass, ret, name, *args)
      argc = args.size
      jmethod = Jmi::Method.new klass, ret, name, args
      if @method_table.include? name
        @method_table[name].push jmethod
      else
        methods = [jmethod]
        @method_table[name] = methods
        block = proc_method(name, methods)
        klass.define_method(safe_name(name), &block)
      end
    end
    def safe_name(name, klass = self)
      while klass.method_defined?(name)
        name += "_java"
      end
      name
    end
    def as_string
      J::TYPE_TABLE[self] = "s"
      @as_string = true
    end
  end
  class Method
    include Jmi::J
  end
  module Generics
    include Definition
    extend J
    def attach(*args)
      if @generics && args.include?(Generics)
        @generics << args
      else
        super
      end
    end
    def [](iclass)
      klass = @table[iclass]
      unless klass
        if self.is_a? ::Class
          klass = ::Class.new force_path(Jmi::Object.class_path(self))
          klass.method_table[nil] = method_table[nil] if method_table[nil]
        else
          klass = ::Class.new Jmi::Object.force_path(Jmi::Object.class_path(self))
          klass.include self
        end
        Jmi.set_classpath klass, "#{self}<#{iclass}>"
        klass.instance_variable_set "@iclass", iclass
        @generics.each do |args|
          klass.attach *args
        end
        @table[iclass] = klass
      end
      klass
    end
    class << self
      def extended(obj)
        obj.instance_variable_set "@table", {}
        obj.instance_variable_set "@generics", []
        obj.class_path = class_path(obj)
      end
    end
  end
  module Interface
    extend J
    include Definition
    def self.extended(klass)
      klass.instance_variable_set "@method_table", {}
      path = class_path(klass)
      NAME_TABLE[path] = klass
      NAME_TABLE[path.gsub("/", ".")] = klass
    end
  end
  class Object
    include J
    extend J
    extend Definition
    def initialize(*args)
      klass = self.class
      methods = klass.method_table[nil]
      raise "#{klass} has no constructor" unless methods
      proc_method("<init>", methods).call(*args)
      self
    end
    class << self
      def inherited(klass)
        klass.instance_variable_set "@method_table", {}
        path = nil
        if @as_string
          klass.as_string
        end
        if @path
          path = @path
          klass.instance_variable_set "@class_path", path
          @path = nil
        else
          path = class_path(klass)
        end
        NAME_TABLE[path] = klass
        NAME_TABLE[path.gsub("/", ".")] = klass
        klass.class_path = path
      end
      def force_path(path)
        @path = path
        self
      end
    end
  end
end
