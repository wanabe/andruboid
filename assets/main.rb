module Jmi
  class Andruboid < Main
    include Android::Widget
    include Android::Graphics
    def initialize
      super

      vlayout = LinearLayout.new(self)
      vlayout.orientation = LinearLayout::VERTICAL
      self.content_view = vlayout

      layout = LinearLayout.new(self)
      vlayout << layout

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

      layout = LinearLayout.new(self)
      vlayout << layout

      edittext = EditText.new(self)
      edittext.typeface = Typeface::MONOSPACE

      layout << edittext
    end
  end
end
