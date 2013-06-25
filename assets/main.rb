class TextView < import("android/widget")
  define_init "Landroid/content/Context;"
  define :setText, "Ljava/lang/CharSequence;", "V"
end

class Mred < JavaMain
  define :setContentView, "Landroid/view/View;", "V"
  def initialize
    textview = TextView.new(self)
    textview.setText("hello from mruby")
    setContentView(textview)
  end
end

