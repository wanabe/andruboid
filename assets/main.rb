module Jmi
  class Mred < Main
    def initialize
      textview = TextView.new(self)
      textview.setText("hello from mruby")
      setContentView(textview)
    end
  end
end
