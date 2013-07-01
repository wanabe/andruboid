module Jmi
  class Andruboid < Main
    include Android::Widget
    def initialize
      layout = LinearLayout.new(self)
      self.content_view = layout

      textview = TextView.new(self)
      textview.text = "hello world   "
      layout << textview

      button = Button.new(self)
      button.text = "button"
      layout << button
    end
  end
end
