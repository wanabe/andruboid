module Jmi
  module Android
    module Widget
      class TextView < Jmi::Object
        define_init "Landroid/content/Context;"
        define :setText, "Ljava/lang/CharSequence;", "V"
        #define  J:Boif, ;name, J;Obj
      end
    end
    module App
      class Activity < Jmi::Object
        define :setContentView, "Landroid/view/View;", "V"
      end
    end
  end

  class Main < Android::App::Activity
    def initialize
    end
    class << self
      def inherited(main)
        super
        @main = main
      end
    end
  end
end

