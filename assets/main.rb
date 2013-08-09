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
      layout << button
      layout << textview

      layout = LinearLayout.new(self)
      vlayout << layout

      edittext = EditText.new(self)
      edittext.typeface = Typeface::MONOSPACE
      edittext.text = "some text"

      layout << edittext

      layout = LinearLayout.new(self)
      vlayout << layout

      adapter = ArrayAdapter[Java::Lang::String].new self, Android::R::Layout::SIMPLE_LIST_ITEM_1
      adapter.add "one"
      adapter.add "two"
      adapter.add "three"
      listview = ListView.new(self)
      listview.adapter = adapter
      listview.on_item_click_listener = Listener.new do |pos|
        edittext.text = "#{adapter.get_item(pos)}"
      end

      layout << listview
    end
  end
end
