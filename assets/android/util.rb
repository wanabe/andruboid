module Jni
  module J
    module Android
      module Util
        class Log < Java::Lang::Object
          attach_static Int, "v", Java::Lang::String, Java::Lang::String
        end
        class AttributeSet < Java::Lang::Object
        end
      end
    end
  end
end

module ::Kernel
  def p(*objs)
    objs.each do |obj|
      Jni::J::Android::Util::Log.v("stdout", obj.inspect)
    end
  end
end
