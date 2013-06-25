class JavaMethod
  def initialize(name, sig)
    @name, @sig = name, sig
  end
end

class JavaObject
  class << self
    attr_writer :package
    attr_writer :class_path
    def define_init(arg)
      @init_sig = "(#{arg})V"
    end
    def define(jname, arg, ret, *names)
      jmethod = JavaMethod.new(jname, "(#{arg})#{ret}")
      names.push jname if names.empty?
      names.each do |name|
        define_method(name) do |*args|
          jmethod.call(self, *args)
        end
      end
    end
    def inherited(klass)
      klass.class_path = "#{@package}/#{klass}"
    end
  end
end

class JavaMain
  class << self
    def inherited(main)
      @main = main
    end
  end
end

def import(package)
  JavaObject.package = package
  JavaObject
end
