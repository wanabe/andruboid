class SystemExit < Exception
end

module Jmi
  module Generics
  end
  module AsString
    module Inner
      def as_string(mod)
        J::TYPE_TABLE[mod] = "s"
      end
      alias inherited as_string
      def included(mod)
        as_string(mod)
        mod.extend Inner
      end
    end
    extend Inner
  end
  module J
    class Void
    end
    class Boolean
    end
    class Float
    end
    class Int
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
      class2item(klass, TYPE_TABLE) || class2sig(klass)
    end
    def get_sig(ret, args)
      ret = class2sig(ret)
      "(#{args.join("")})#{ret}"
    end
    NAME_TABLE = {
      "int" => Int,
      "boolean" => Boolean,
      "float" => Float
    }
    def name2class(name)
      NAME_TABLE[name]
    end
  end
  module Definition
    include Jmi::J
    attr_reader :init_method
    def attach_init(*args)
      args.map! {|a| class2sig(a)}
      @init_args = args
      @init_method = Jmi::Method.new self, Void, "<init>", args
    end
    def attach(ret, name, *args)
      attach_at self, ret, name, *args
    end
    def attach_static(ret, name, *args)
      attach_at singleton_class, ret, name, *args
    end
    def attach_const(ret, name)
      val = Jmi.get_field_static self, ret, name
      const_set name, val
    end
     def attach_at(klass, ret, name, *args)
      argc = args.size
      args.map! {|a| class2sig(a)}
      jmethod = Jmi::Method.new klass, ret, name, args
      klass.define_method(name) do |*args|
        jmethod.call self, name, args
      end
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
        klass = ::Class.new Jmi::Object.force_path(Jmi::Object.class_path(self))
        Jmi.set_classpath klass, "#{self}<#{iclass}>"
        klass.include self
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
  class Object
    include J
    extend J
    extend Definition
    def initialize(*args)
      init = self.class.init_method
      raise "#{self.class} has no consructor" unless init
      init.call self, :initialize, args
    end
    class << self
      def inherited(klass)
        path = nil
        if @path
          path = @path
          klass.instance_variable_set "@class_path", path
          @path = nil
        else
          path = class_path(klass)
        end
        NAME_TABLE[path.gsub("/", ".")] = klass
        klass.class_path = path
        if @init_args
          init_method = Jmi::Method.new klass, Void, "<init>", @init_args
          klass.instance_variable_set "@init_args", @init_args
          klass.instance_variable_set "@init_method", init_method
        end
      end
      def force_path(path)
        @path = path
        Jmi::Object
      end
    end
  end
end
