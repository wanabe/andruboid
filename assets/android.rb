module Jmi
  module Android
    module Widget
      class TextView < Jmi::Object
        define_init "Landroid/content/Context;"
        define "V", "set_text", "Ljava/lang/CharSequence;"
      end
    end
    module App
      class Activity < Jmi::Object
        define "V", "set_content_view", "Landroid/view/View;"
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

