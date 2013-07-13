module Jmi
  class Andruboid < Main
    include Android::Widget
    def initialize
      super
      layout = LinearLayout.new(self)
      self.content_view = layout

      textview = TextView.new(self)
      textview.text = "hello world   "

      checkbox = CheckBox.new(self)
      checkbox.checked = true
      checkbox.text = "check_box"
      checkbox.on_click_listener = ClickListener.new do
        Toast.make_text(self, "checkbox is #{checkbox.is_checked}", Toast::LENGTH_SHORT).show
      end

      button = Button.new(self)
      button.text = "exit"
      button.on_click_listener = ClickListener.new do
        exit
      end

      layout << textview
      layout << checkbox
      layout << button
    end
  end
end
