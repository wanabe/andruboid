module Jmi
  module J
    module Java
      module Lang
        class CharSequence
        end
      end
    end
    module Android
      module Content
        class Context
        end
      end
      module View
        class View
        end
      end
      module Widget
        class TextView < Jmi::Object
          define_init Android::Content::Context
          define Void, "set_text", Java::Lang::CharSequence
        end
      end
      module App
        class Activity < Jmi::Object
          define Void, "set_content_view", Android::View::View
        end
      end
    end
  end

  class Main < J::Android::App::Activity
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

