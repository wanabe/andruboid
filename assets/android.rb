module Jmi
  class TextView < import("android/widget")
    define_init "Landroid/content/Context;"
    define :setText, "Ljava/lang/CharSequence;", "V"
    #define  J:Boif, ;name, J;Obj
  end

  class Main
    define :setContentView, "Landroid/view/View;", "V"
  end
end

