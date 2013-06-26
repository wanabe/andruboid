module Jmi
  class Method
    def initialize(name, sig)
      @name, @sig = name, sig
    end
  end

  class Object
    class << self
      attr_writer :package
      attr_writer :class_path
      def define_init(arg)
        @init_sig = "(#{arg})V"
      end
      def define(jname, arg, ret, *names)
        jmethod = Jmi::Method.new(jname, "(#{arg})#{ret}")
        names.push jname if names.empty?
        names.each do |name|
          define_method(name) do |*args|
            jmethod.call(self, *args)
          end
        end
      end
      def inherited(klass)
        name = klass.to_s
        colon = name.rindex(":")
        name = name[colon + 1..-1] if colon
        klass.class_path = "#{@package}/#{name}"
      end
    end
  end
 
  class Main
    class << self
      def inherited(main)
        @main = main
      end
    end
  end
  class << self
    def import(package)
      Jmi::Object.package = package
      Jmi::Object
    end
  end
end


