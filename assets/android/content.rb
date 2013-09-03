module Jni
  module J
    module Android
      module Content
        class Context < Java::Lang::Object
        end
        module Res
          class Resources < Java::Lang::Object
            attach_static self, "getSystem"
            attach Android::Graphics::Drawable::Drawable, "getDrawable", Int
          end
        end
        module Pm
          class PackageManager < Java::Lang::Object
          end
          class ApplicationInfo < Java::Lang::Object
            attach Java::Lang::CharSequence, "loadDescription", PackageManager
            attach Java::Lang::String, "toString"
          end
          class PackageManager < Java::Lang::Object
            attach Java::Util::List[ApplicationInfo], "getInstalledApplications", Int
          end
        end
        class DialogInterface < Java::Lang::Object
          module OnClickListener
            extend Interface
          end
          attach_const Int, "BUTTON_NEGATIVE"
          attach_const Int, "BUTTON_NEUTRAL"
          attach_const Int, "BUTTON_POSITIVE"
        end
      end
    end
  end
end
