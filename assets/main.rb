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
      listview.on_scroll_listener = Listener.new(Listener::ON_SCROLL_STATE_CHANGED) do |state|
        if state != 0
          param = LinearLayout::LayoutParams.new(LinearLayout::LayoutParams::MATCH_PARENT, LinearLayout::LayoutParams::MATCH_PARENT, 100)
          listview.layout_params = param
        end
      end
      listview.on_item_click_listener = Listener.new do |pos|
        @layout.orientation = LinearLayout::VERTICAL
        param = LinearLayout::LayoutParams.new(LinearLayout::LayoutParams::MATCH_PARENT, LinearLayout::LayoutParams::MATCH_PARENT, 250)
        listview.layout_params = param
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
    def spinner
      adapter = ArrayAdapter[Java::Lang::String].new self, Android::R::Layout::SIMPLE_SPINNER_ITEM
      adapter.drop_down_view_resource = Android::R::Layout::SIMPLE_SPINNER_DROPDOWN_ITEM
      ["i", "ro", "ha", "ni", "ho", "he", "to"].each do |str|
        adapter.add str
      end
      spinner = Spinner.new(self)
      spinner.adapter = adapter
      @passed = false
      spinner.on_item_selected_listener = Listener.new do |pos|
        if @passed
          adapter.add "selected '#{adapter[pos]}'"
        else
          @passed = true
        end
      end
      @layout << spinner
    end
    def rating_bar
      @layout.orientation = LinearLayout::HORIZONTAL
      ratingbar = RatingBar.new(self)
      ratingbar.num_stars = 3
      ratingbar.rating = 2
      @layout << ratingbar
    end
    def seek_bar
      seekbar = SeekBar.new(self)
      seekbar.max = 100
      seekbar.progress = 30
      param = ViewGroup::LayoutParams.new(ViewGroup::LayoutParams::MATCH_PARENT, LinearLayout::LayoutParams::WRAP_CONTENT)
      seekbar.layout_params = param
      @layout << seekbar
    end
    def progress_bar
      progressbar = ProgressBar.new(self, nil, Android::R::Style::WIDGET_PROGRESSBAR_HORIZONTAL)
      progressbar.progress_drawable = Android::Content::Res::Resources.system.get_drawable Android::R::Drawable::PROGRESS_HORIZONTAL
      progressbar.max = 100
      progressbar.progress = 30
      param = ViewGroup::LayoutParams.new(ViewGroup::LayoutParams::MATCH_PARENT, LinearLayout::LayoutParams::WRAP_CONTENT)
      progressbar.layout_params = param
      @layout << progressbar

      progressbar = ProgressBar.new(self)
      progressbar.max = 100
      progressbar.progress = 30
      @layout << progressbar
    end
  end
end
