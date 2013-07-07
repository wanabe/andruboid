module Jmi
  class Andruboid < Main
    include Android::Widget
    def initialize
      super
      layout = LinearLayout.new(self)
      self.content_view = layout

      textview = TextView.new(self)
      textview.text = "hello world   "

      button = Button.new(self)
      button.text = "button"
      button.on_click_listener = ClickListener.new do
        textview.text = package_manager.inspect
      end

      layout << button
      layout << textview
    end
  end
end
