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
      checkbox.text = "check_box  "
      checkbox.on_click_listener = Listener.new do
        Toast.make_text(self, "checkbox is #{checkbox.is_checked}", Toast::LENGTH_SHORT).show
      end

      radiogroup = RadioGroup.new(self)
      ["1st", "2nd", "3rd"].each do |text|
        radiobutton = RadioButton.new(self)
        radiobutton.text = text
        radiobutton.on_click_listener = Listener.new do
          textview.text = text
        end
        radiogroup << radiobutton
      end

      button = Button.new(self)
      button.text = "exit"
      button.on_click_listener = Listener.new do
        exit
      end

      layout << radiogroup
      layout << checkbox
      layout << textview
      layout << button
    end
  end
end
