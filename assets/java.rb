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

