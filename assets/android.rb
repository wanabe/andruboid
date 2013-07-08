module Jmi
  module J
    module Com
      module Github
        module Wanabe
          class Andruboid
          end
        end
      end
    end
    module Java
      module Lang
        class CharSequence
        end
        class String < CharSequence
        end
      end
      module Util
        module List
          extend Generics
          define Int, "size"
          define Generics, "get", Int
        end
      end
    end
    module Android
      module Content
        class Context
        end
        module Pm
          class ApplicationInfo < Jmi::Object
            #define 
          end
          class PackageManager < Jmi::Object
            define Java::Util::List[ApplicationInfo], "get_installed_applications", Int
          end
        end
      end
      module View
        class View
          module OnClickListener
          end
        end
      end
      module Widget
        class LinearLayout < Jmi::Object
          define_init Android::Content::Context
          define Void, ["add_view", "<<"], Android::View::View
        end
        class TextView < Jmi::Object
          define_init Android::Content::Context
          define Void, "set_text", Java::Lang::CharSequence
        end
        class Button < Jmi::Object
          define_init Android::Content::Context
          define Void, "set_text", Java::Lang::CharSequence
          define Void, "set_on_click_listener", Android::View::View::OnClickListener
        end
      end
      module App
        class Activity < Jmi::Object
          define Void, "set_content_view", Android::View::View
          define Android::Content::Pm::PackageManager, "get_package_manager"
        end
      end
    end
  end

  class Main < J::Android::App::Activity
    def initialize
      Jmi::Main.main = self
    end
    class << self
      attr_accessor :main
      def inherited(main)
        super
        @main = main
      end
    end
  end

  class ClickListener < Jmi::Object.force_path("com/github/wanabe/Andruboid$ClickListener")
    @table = []
    define_init Com::Github::Wanabe::Andruboid,Int
    def initialize(&block)
      klass = self.class
      id = klass.push block
      super Jmi::Main.main, id
    end
    class << self
      def push(block)
        id = @table.size
        @table.push block
        id
      end
      def call(id)
        @table[id].call
      end
    end
  end
end

