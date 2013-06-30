module Jmi
  module J
    def class_path(klass)
      path = nil
      until (path = klass.to_s).index("Jmi::J::")
        klass = klass.superclass
        raise "#{self} is not Java class/interface" unless klass
      end
      path = path[8..-1].split("::")

      path[0, path.length - 1].each {|s| s.downcase!}
      path.join("/")
    end
    class Void
    end
  end
  class Object
    include Jmi::J
    extend Jmi::J
    def initialize(*args)
      self.class.init_method.call self, :initialize, *args
    end
    class << self
      attr_reader :init_method
      def define_init(*args)
        args.map! {|a| class2sig(a)}
        @init_method = Jmi::Method.new self, "<init>", "(#{args.join('')})V"
      end
      def define(ret, names, *args)
        names = [names] unless names.is_a? Array
        names.push names.first[4..-1] if names.first.index("get_") == 0
        names.push "#{names.first[4..-1]}=" if names.first.index("set_") == 0
        jname = names.first.split "_"
        jname[1, jname.length].each {|s| s.capitalize!}
        jname = jname.join("")
        names.push jname

        args.map! {|a| class2sig(a)}
        jmethod = Jmi::Method.new self, jname, "(#{args.join('')})#{class2sig(ret)}"
        names.each do |name|
          define_method(name) do |*margs|
            jmethod.call self, name, *margs
          end
        end
      end
      def class2sig(klass)
        if klass == Void
          "V"
        else
          "L#{class_path(klass)};"
        end
      end
      def inherited(klass)
        klass.class_path = class_path(klass)
      end
    end
  end
end

