module Jmi
  module J
    module Java
      module Lang
        module Reflect
          class Field < Java::Lang::Object
            def static?
              modifiers & Modifier::STATIC != 0
            end
            def final?
              modifiers & Modifier::FINAL != 0
            end
            def public?
              modifiers & Modifier::PUBLIC != 0
            end
          end
        end
        class << Object
          def inherited(klass)
            super
            klass.attach_auto
          end
        end
      end
    end
  end
  class << J::Java::Lang::Class
    def attach(ret, names, *args)
      classclass = self
      names = super
      names.each do |name|
        Jmi::Object.singleton_class.define_method(name) do |*argv|
          @jclassobj.send(name, *argv)
        end
      end
    end
  end
  module JClass
    def attach_auto
      klass = Java::Lang::Class.for_name(class_path(self, "."))
      klass.declared_fields.each do |field|
        type = field.type
        next if type.is_a? Java::Lang::Class
        next unless field.public? && field.static? && field.final?
        attach_const field.type, field.name
      end
    end
  end
end
