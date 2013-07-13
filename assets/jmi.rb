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
    class Bool
    end
    class Int
    end
    def class_path(klass)
      path = klass.instance_variable_get "@class_path"
      return path if path

      until (path = klass.to_s).index("Jmi::J::")
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
          s.replace s + "/"
        end
      end
      path.join("")
    end
    SIG_TABLE = {
      Void => "V",
      Bool => "Z",
      Int => "I",
      Generics => "Ljava/lang/Object;"
    }
    SIG_TABLE.extend self
    SIG_TABLE.default_proc = lambda do |h, k|
      h[k] = "L#{SIG_TABLE.class_path(k)};"
    end
    TYPE_TABLE = {
      nil => "c"
    }
    def class2sig(klass)
      SIG_TABLE[klass]
    end
    def class2type(klass)
      TYPE_TABLE[klass] || SIG_TABLE[klass]
    end
    def get_sig(ret, args)
      ret = class2sig(ret)
      #args = args.map{|a| class2sig(a)}
      "(#{args.join("")})#{ret}"
    end
  end
  module JClass
    include Jmi::J
    attr_reader :init_method
    def attach_init(*args)
      args.map! {|a| class2sig(a)}
      @init_method = Jmi::Method.new self, Void, "<init>", args
    end
    def attach(ret, names, *args)
      attach_at self, ret, names, *args
    end
    def attach_static(ret, names, *args)
      attach_at singleton_class, ret, names, *args
    end
    def attach_const(ret, name)
      val = Jmi.get_field_static self, ret, name
      const_set name, val
    end
    def attach_at(klass, ret, names, *args)
      type = opt = nil
      names = [names] unless names.is_a? Array

      name = names.first
      argc = args.size
      case argc
      when 0
        case
        when name.index("get_") == 0
          opt = name[4..-1]
          names.push opt
          type = :get
        when name == "to_string"
          names.push "to_s"
        end
      when 1
        case
        when name.index("set_") == 0
          opt = names.first[4..-1]
          names.push "#{opt}="
          opt = "@#{opt}"
          type = :set
        when name.index("add_") == 0
          opt = "@#{names.first[4..-1]}"
          type = :add
        end
      end

      jname = names.first.split "_"
      jname[1, jname.length].each {|s| s.capitalize!}
      jname = jname.join("")
      names.push jname

      args.map! {|a| class2sig(a)}
      jmethod = Jmi::Method.new klass, ret, jname, args
      names.each do |name|
        case type
        when :set
          klass.define_method(name) do |arg|
            jmethod.call self, name, [arg]
            instance_variable_set opt, arg
          end
        when :add
          klass.define_method(name) do |arg|
            args = [arg]
            jmethod.call self, name, args
            list = instance_variable_get opt
            if list
              list << arg
            else
              instance_variable_set opt, args
            end
          end
        else
          klass.define_method(name) do |*args|
            jmethod.call self, name, args
          end
        end
      end
    end
  end
  class Method
    include Jmi::J
  end
  module Generics
    include JClass
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
        klass = Class.new Jmi::Object.force_path(Jmi::Object.class_path(self))
        Jmi::Object.inherited klass # todo
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
    extend JClass
    def initialize(*args)
      init = self.class.init_method
      raise "#{self.class} has no consructor" unless init
      init.call self, :initialize, args
    end
    class << self
      def inherited(klass)
        if @path
          klass.instance_variable_set "@class_path", @path
          klass.class_path = @path
          @path = nil
          return
        end
        klass.class_path = class_path(klass)
      end
      def force_path(path)
        @path = path
        Jmi::Object
      end
    end
  end
end
