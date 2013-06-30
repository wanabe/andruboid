module Jmi
  class Object
    def initialize(*args)
      self.class.init_method.call self, :initialize, *args
    end
    class << self
      attr_reader :init_method
      def define_init(arg)
        @init_method = Jmi::Method.new self, "<init>", "(#{arg})V"
      end
      def define(ret, names, arg)
        names = [names] unless names.is_a? Array
        names.push names.first[4..-1] if names.first.index("get_") == 0
        names.push "#{names.first[4..-1]}=" if names.first.index("set_") == 0
        jname = names.first.split "_"
        jname[1, jname.length].each {|s| s.capitalize!}
        jname = jname.join("")
        names.push jname
        jmethod = Jmi::Method.new self, jname, "(#{arg})#{ret}"
        names.each do |name|
          define_method(name) do |*args|
            jmethod.call self, name, *args
          end
        end
      end
      def inherited(klass)
        java_class = klass
        path = nil
        while true # TODO: for Main
          path = java_class.to_s.split("::")
          break if path.size > 2
          java_class = java_class.superclass
        end
        path.shift
        path[0, path.length - 1].each {|s| s.downcase!}
        klass.class_path = path.join("/")
      end
    end
  end
end

