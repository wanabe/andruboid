module Jni
  module J
    module Android
      class R
        class Layout < Java::Lang::Object.force_path("android/R$layout")
          attach_const Int, "simple_list_item_1"
          attach_const Int, "simple_spinner_item"
          attach_const Int, "simple_spinner_dropdown_item"
        end
        class Style < Java::Lang::Object.force_path("android/R$style")
          attach_const Int, "Widget_ProgressBar_Horizontal"
        end
        class Drawable < Java::Lang::Object.force_path("android/R$drawable")
          attach_const Int, "progress_horizontal"
        end
      end
    end
  end
end
