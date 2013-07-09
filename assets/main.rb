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
        pm = package_manager
        list = pm.get_installed_applications(0)
        buffer = ""
        (0..20).each do |i|
          app = list.get(i)
          tos = app.to_string
          desc = app.load_description(pm)
          buffer += "#{tos} #{desc}\n"
        end
        textview.text = buffer
      end

      layout << button
      layout << textview
    end
  end
end
