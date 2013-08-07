module Jmi
  module J
    module Java
      module Lang
        module Reflect
          class Field < Java::Lang::Object
            attach Java::Lang::String, "toString"
          end
        end
        class Object < Jmi::Object
          attach Class, "getClass"
        end
        class Class < Java::Lang::Object
          attach String, "getName"
          attach [Reflect::Field], "getFields"
        end
      end
      module Util
        module List
          extend Generics
          extend Interface
          attach Int, "size"
          attach Generics, "get", Int
        end
      end
    end
  end
end
