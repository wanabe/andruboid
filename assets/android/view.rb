module Jmi
  module J
    module Android
      module View
        class View < Java::Lang::Object
          module OnClickListener
            extend Interface
          end
        end
        class ViewGroup < View
          class LayoutParams < Java::Lang::Object
            attach_init Int, Int
            attach_const Int, "WRAP_CONTENT"
            attach_const Int, "MATCH_PARENT"
          end
          attach Void, "addView", Android::View::View
          attach Void, "addView", Android::View::View, LayoutParams
          alias << addView
          attach Void, "removeAllViews"
          alias remove_all remove_all_views
        end
        class View
          attach_auto
          attach_const Int, "LAYER_TYPE_SOFTWARE"
          attach Void, "setLayoutParams", ViewGroup::LayoutParams
          attach Void, "setOnClickListener", OnClickListener
          attach Void, "setLayerType", Int, Graphics::Paint
        end
      end
    end
  end
end
