module Jmi
  class Andruboid < Main
    include Android::Widget
    def initialize
      super
      layout = LinearLayout.new(self)
      self.content_view = layout
      main = self

      textview = TextView.new(self)
      textview.text = "hello world   "

      checkbox = CheckBox.new(self)
      checkbox.checked = true

      button = Button.new(self)
      button.text = "button"
      button.on_click_listener = ClickListener.new do
        Toast.make_text(main, "checkbox is #{checkbox.is_checked}", Toast::LENGTH_SHORT).show
      end

      layout << button
      layout << textview
      layout << checkbox
    end
  end
end
