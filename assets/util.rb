module Jmi
  class << J::Java::Lang::Class
    def attach(ret, name, *args)
      super
      Jmi::Object.singleton_class.define_method(name) do |*argv|
        @jclassobj.send(name, *argv)
      end
    end
  end
  J::TYPE_TABLE[J::Java::Lang::Class] = "c"
  module JClass
    def attach_auto
      klass = Java::Lang::Class.for_name(class_path(self))
      klass.declared_fields.each do |field|
        type = field.type
      end
    end
  end
end