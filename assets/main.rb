module Jmi
  class Andruboid < Main
    include Android::Widget
    def initialize
      layout = LinearLayout.new(self)
      self.content_view = layout

      textview = TextView.new(self)
      textview.text = "hello world   "
      layout << textview

      textview2 = TextView.new(self)
      textview2.text = "from mruby"
      layout << textview2
    end
  end
end
