module Jmi
  class Mred < Main
    include Android::Widget
    def initialize
      textview = TextView.new(self)
      textview.setText("hello from mruby")
      setContentView(textview)
    end
  end
end
