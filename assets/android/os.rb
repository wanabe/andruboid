module Jni
  module J
    module Android
      module Os
        class Process < Java::Lang::Object
          attach_static Void, "killProcess", Int
          attach_static Int, "myPid"
        end
      end
    end
  end
end
