module Jmi
  module J
    module Java
      module Lang
        class Class < Jmi::Object
        end
        class CharSequence < Jmi::Object
          include AsString
        end
        class String < CharSequence
        end
        module Reflect
          class Field < Jmi::Object
            attach Java::Lang::String, "to_string"
            attach Java::Lang::String, "get_name"
            attach Java::Lang::Class, "get_type"
            attach Int, "get_modifiers"
          end
        end
        class Object < Jmi::Object
          alias rb_class class
          attach Class, "get_class"
          alias class rb_class
        end
        class Class < Jmi::Object
          attach String, "get_name"
          attach [Reflect::Field], "get_fields"
          attach [Reflect::Field], "get_declared_fields"
          attach_static Class, "for_name", String
        end
      end
      module Util
        module List
          extend Generics
          attach Int, "size"
          attach Generics, "get", Int
        end
      end
    end
  end
end
