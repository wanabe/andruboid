module Jmi
  module Android
    module Widget
      class TextView < Jmi::Object
        define_init "Landroid/content/Context;"
        define :setText, "Ljava/lang/CharSequence;", "V"
        #define  J:Boif, ;name, J;Obj
      end
    end
  end

  class Main
    define :setContentView, "Landroid/view/View;", "V"
  end
end

