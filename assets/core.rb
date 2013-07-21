module Jmi
  module J
    module Java
      module Lang
        class Class < Jmi::Object
        end
        module Reflect
          class Modifier < Jmi::Object
            attach_const Int, "STATIC"
            attach_const Int, "FINAL"
            attach_const Int, "PUBLIC"
          end
        end
      end
    end
  end
end
