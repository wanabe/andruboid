module Jni
  class Andruboid < Main
    include Java::Util
    include Android::App
    include Android::View
    include Android::Widget
    include Android::Content
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
      @table = self.class.method_table
      @table.each do |name|
        name = name.to_s.split("_").map{|n| n.capitalize}.join("")
        adapter.add name
      end
      @listview = ListView.new(self)
      @listview.adapter = adapter
      @listview.on_scroll_listener = Listener.new(Listener::ON_SCROLL_STATE_CHANGED) do |state|
        if state != 0
          param = LinearLayout::LayoutParams.new(LinearLayout::LayoutParams::MATCH_PARENT, LinearLayout::LayoutParams::MATCH_PARENT, 50)
          @listview.layout_params = param
        end
      end
      @listview.on_item_click_listener = Listener.new do |pos|
        @layout.orientation = LinearLayout::VERTICAL
        param = LinearLayout::LayoutParams.new(LinearLayout::LayoutParams::MATCH_PARENT, LinearLayout::LayoutParams::MATCH_PARENT, 100)
        @listview.layout_params = param
        @layout.remove_all_views
        __send__ @table[pos]
      end
      param = LinearLayout::LayoutParams.new(LinearLayout::LayoutParams::MATCH_PARENT, LinearLayout::LayoutParams::MATCH_PARENT, 50)
      @listview.layout_params = param
      vlayout << @listview

      @layout = LinearLayout.new(self)
      param = LinearLayout::LayoutParams.new(LinearLayout::LayoutParams::MATCH_PARENT, LinearLayout::LayoutParams::MATCH_PARENT, 100)
      @layout.layout_params = param
      vlayout << @layout
    end

    @method_table = instance_methods(false)
    def _how_to_use
      builder = AlertDialog::Builder.new self
      builder.title = "How to use andruboid"
      builder.message = "\
       When you run andruboid at first,\
      it creates 'andruboid' directory\
      in sdcard.\
       You can change the scripts in
      this directory to write a application.\
      bootstrup script is 'setup.rb'.\
      ".sub!("\n", "").gsub!("      ", "")
      builder.set_positive_button "OK", nil#listener

      dialog = builder.create
      dialog.show
      
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
    def progress_dialog
      dialog = ProgressDialog.new self
      dialog.title = "ProgressDialog"
      dialog.message = "this dialog shows progress"
      dialog.indeterminate = false
      dialog.progress_style = ProgressDialog::STYLE_HORIZONTAL
      dialog.max = 100
      dialog.increment_progress_by 30
      dialog.increment_secondary_progress_by 70
      dialog.cancelable = true
      dialog.show
    end
    def alert_dialog
      builder = AlertDialog::Builder.new self
      builder.title = "AlertDialog"
      builder.message = "this is dialog message"
      listener = Listener.new do |which|
        ans = case which
        when DialogInterface::BUTTON_POSITIVE
          "yes"
        when DialogInterface::BUTTON_NEGATIVE
          "no"
        when DialogInterface::BUTTON_NEUTRAL
          "skip"
        end
        Toast.make_text(self, "you said '#{ans}'", Toast::LENGTH_SHORT).show
      end
      builder.set_positive_button "Yes", listener
      builder.set_negative_button "No", listener
      builder.set_neutral_button "Skip", listener

      dialog = builder.create
      dialog.show
    end
    def calendar_picker_dialog
      calendar = Calendar.instance
      year = calendar.get(Calendar::YEAR)
      month = calendar.get(Calendar::MONTH)
      day = calendar.get(Calendar::DAY_OF_MONTH)
      listener = Listener.new do |y, m, d|
        Toast.make_text(self, "#{y}/#{m + 1}/#{d}", Toast::LENGTH_SHORT).show
      end
      dialog = DatePickerDialog.new(self, listener, year, month, day)
      dialog.show
    end
    def time_picker_dialog
      calendar = Calendar.instance
      hour = calendar[Calendar::HOUR_OF_DAY]
      minute = calendar[Calendar::MINUTE]
      listener = Listener.new do |h, m|
        Toast.make_text(self, "#{h}:#{m}", Toast::LENGTH_SHORT).show
      end
      dialog = TimePickerDialog.new(self, listener, hour, minute, true)
      dialog.show
    end
    def analog_clock
      clock = AnalogClock.new self
      @layout << clock
    end
    def digital_clock
      clock = DigitalClock.new self
      @layout << clock
    end
    def chronometer
      chrono = Chronometer.new self
      chrono.format = "click to start/stop chronometer %s"
      chrono.start
      @started = true
      chrono.on_click_listener = Listener.new do
        if @started
          chrono.stop
        else
          chrono.start
        end
        @started = !@started
      end
      @layout << chrono
    end
    def custom_view
      customview = CustomView.new self
      customview.set_layer_type(View::LAYER_TYPE_SOFTWARE, nil)
      customview.on_draw = Listener.new do |canvas|
        paint = Paint.new
        paint.anti_alias = true
        paint.color = Color.argb 255, 164, 199, 57

        canvas.draw_argb 255, 255, 255, 255

        clip_path = Path.new
        clip_path.add_circle 140, 80, 3, Path::Direction::CW
        clip_path.add_circle 170, 80, 3, Path::Direction::CW
        begin
          canvas.clip_path clip_path, Region::Op::DIFFERENCE
        rescue Exception => e
          # draw white eyes after if clip_path is unsupported
          Jni.clear_exception
        else
          clip_path = nil
        end

        path = Path.new
        path.add_round_rect RectF.new(102, 95, 117, 145), 7, 7, Path::Direction::CW
        path.add_round_rect RectF.new(193, 95, 208, 145), 7, 7, Path::Direction::CW
        path.add_rect RectF.new(120, 98, 190, 145), Path::Direction::CW
        path.add_round_rect RectF.new(120, 140, 190, 150), 5, 5, Path::Direction::CW
        path.add_round_rect RectF.new(135, 140, 150, 175), 7, 7, Path::Direction::CW
        path.add_round_rect RectF.new(160, 140, 175, 175), 7, 7, Path::Direction::CW
        path.add_arc RectF.new(120, 63, 190, 127), 180, 180
        path.move_to 140, 70
        path.line_to 130, 55
        path.line_to 131, 54
        path.line_to 141, 69
        path.move_to 170, 70
        path.line_to 180, 55
        path.line_to 182, 54
        path.line_to 172, 69

        canvas.draw_path path, paint
        if clip_path
          paint.color = Color.argb 255, 255, 255,255
          canvas.draw_path clip_path, paint
        end
        paint.color = Color.argb 255, 0, 128, 192

        canvas.draw_point 10, 20, paint
        pts = [20, 30, 30, 40]
        canvas.draw_points pts, paint

        canvas.draw_line 0, 0, 100, 50, paint
        pts = [50, 0, 50, 30, 0, 50, 20, 50]
        canvas.draw_lines pts, paint

        rect = RectF.new 240.5, 20.5, 260.5, 40.5
        canvas.draw_rect rect, paint

        paint.style = Paint::Style::STROKE
        canvas.draw_rect 210, 50, 230, 80, paint

        paint.style = Paint::Style::FILL
        canvas.draw_circle 220, 30, 10, paint

        oval = RectF.new 240.5, 50.5, 260.5, 80.5
        canvas.draw_oval oval, paint

        paint.style = Paint::Style::STROKE
        oval = RectF.new 280.0, 20.0, 320.0, 60.0
        canvas.draw_arc oval, 90, 135, true, paint

        paint.style = Paint::Style::FILL
        oval = RectF.new 320.0, 20.0, 360.0, 60.0
        canvas.draw_arc oval, 90, 135, false, paint
      end
      @layout << customview
    end
    @method_table = instance_methods(false) - @method_table
    @method_table.sort!
    def self.method_table
      @method_table
    end
  end
end
