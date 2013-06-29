module Jmi
  class Mred < Main
    include Android::Widget
    def initialize
      textview = TextView.new(self)
      textview.text = "hello from mruby"
      self.content_view = textview
    end
  end
end
