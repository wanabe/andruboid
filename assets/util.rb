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
  end
  module JClass
    def attach_auto
      path = class_path(self, ".")
      klass = Java::Lang::Class.for_name(path)
      klass.declared_fields.each do |field|
        type = field.type
        next if type.is_a? Java::Lang::Class
        next unless field.public? && field.static? && field.final?
        attach_const field.type, field.name
      end
    end
  end
  module J::Java::Lang
    Object.attach_auto
    Class.attach_auto
    CharSequence.attach_auto
    String.attach_auto
    Reflect::Modifier.attach_auto
    Reflect::Field.attach_auto
  end
end
