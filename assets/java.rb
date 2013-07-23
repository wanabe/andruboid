module Jmi
  module J
    module Java
      module Lang
        module Reflect
          class Field < Java::Lang::Object
            attach Java::Lang::String, "to_string"
          end
        end
        class Object < Jmi::Object
          alias rb_class class
          attach Class, "get_class"
          alias class rb_class
        end
        class Class < Java::Lang::Object
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
