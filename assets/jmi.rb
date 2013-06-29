module Jmi
  class Object
    def initialize(*args)
      self.class.init_method.call self, *args
    end
    class << self
      attr_reader :init_method
      def define_init(arg)
        @init_method = Jmi::Method.new self, "<init>".intern, "(#{arg})V"
      end
      def define(jname, arg, ret, *names)
        jmethod = Jmi::Method.new self, jname, "(#{arg})#{ret}"
        names.push jname if names.empty?
        names.each do |name|
          define_method(name) do |*args|
            jmethod.call self, *args
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

