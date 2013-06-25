class TextView < import("android/widget")
  define_init "Landroid/content/Context;"
  define :setText, "Ljava/lang/CharSequence;", "V"
end

class JavaMain
  define :setContentView, "Landroid/view/View;", "V"
end

