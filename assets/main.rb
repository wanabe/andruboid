module Jmi
  class Andruboid < Main
    include Android::View
    include Android::Widget
    include Android::Graphics
    def initialize
      super

      vlayout = LinearLayout.new(self)
      vlayout.orientation = LinearLayout::VERTICAL
      self.content_view = vlayout

      button = Button.new(self)
      button.text = "exit"
      button.on_click_listener = Listener.new do
        exit
      end
      vlayout << button

      adapter = ArrayAdapter[Java::Lang::String].new self, Android::R::Layout::SIMPLE_LIST_ITEM_1
      @table = self.class.instance_methods(false).sort
      @table.delete :initialize
      @table.each do |name|
        name = name.to_s.split("_").map{|n| n.capitalize}.join("")
        adapter.add name
      end
      listview = ListView.new(self)
      listview.adapter = adapter
      listview.on_item_click_listener = Listener.new do |pos|
        param = LinearLayout::LayoutParams.new(LinearLayout::LayoutParams::MATCH_PARENT, LinearLayout::LayoutParams::MATCH_PARENT, 40)
        @layout.layout_params = param
        @layout.remove_all_views
        __send__ @table[pos]
      end
      param = LinearLayout::LayoutParams.new(LinearLayout::LayoutParams::MATCH_PARENT, LinearLayout::LayoutParams::MATCH_PARENT, 100)
      listview.layout_params = param
      vlayout << listview

      @layout = LinearLayout.new(self)
      param = LinearLayout::LayoutParams.new(LinearLayout::LayoutParams::MATCH_PARENT, LinearLayout::LayoutParams::MATCH_PARENT, 100)
      @layout.layout_params = param
      vlayout << @layout
    end
    def button
      button = Button.new(self)
      button.text = "button"
      button.on_click_listener = Listener.new do
        button.text = "pushed"
      end
      @layout << button
    end
    def text_view
      textview = TextView.new(self)
      textview.text = "text view\ncan contain\nmulti\nline\nline\nline\nline\nline"
      @layout << textview
    end
    def check_box
      checkbox = CheckBox.new(self)
      checkbox.checked = true
      checkbox.text = "checked"
      checkbox.on_click_listener = Listener.new do
        prefix = checkbox.is_checked ? "" : "not "
        checkbox.text = "#{prefix}checked"
      end
      @layout << checkbox
    end
    def radio_group
      radiogroup = RadioGroup.new(self)
      ["1st", "2nd", "3rd"].each do |text|
        radiobutton = RadioButton.new(self)
        radiobutton.text = text
        radiobutton.on_click_listener = Listener.new do
          Toast.make_text(self, text, Toast::LENGTH_SHORT).show
        end
        radiogroup << radiobutton
      end
      @layout << radiogroup
    end
    def edit_text
      edittext = EditText.new(self)
      edittext.typeface = Typeface::MONOSPACE
      edittext.text = "edit text"
      @layout << edittext
    end
    def toast
      Toast.make_text(self, "toast", Toast::LENGTH_LONG).show
    end
    def list_view
      adapter = ArrayAdapter[Java::Lang::String].new self, Android::R::Layout::SIMPLE_LIST_ITEM_1
      ["red", "green", "blue"].each do |name|
        adapter.add name
      end
      listview = ListView.new(self)
      listview.adapter = adapter
      listview.on_item_click_listener = Listener.new do |pos|
        adapter.add "selected '#{adapter[pos]}'"
      end
      @layout << listview
    end
  end
end
