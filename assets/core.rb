module Jmi
  module J
    module Java
      module Lang
        class Object < Jmi::Object
        end
        class Class < Java::Lang::Object
          J::TYPE_TABLE[self] = "c"
        end
        class CharSequence < Java::Lang::Object
          include AsString
        end
        class String < CharSequence
        end
        module Reflect
          class Modifier < Java::Lang::Object
            attach_const Int, "STATIC"
            attach_const Int, "FINAL"
            attach_const Int, "PUBLIC"
          end
          class Field < Java::Lang::Object
            attach Int, "get_modifiers"
            attach Java::Lang::String, "get_name"
            attach Java::Lang::Class, "get_type"
          end
        end
      end
    end
  end
end
