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
        class CharSequence < Jmi::Object
          include AsString
        end
        class String < CharSequence
        end
      end
      module Util
        module List
          extend Generics
          attach Int, "size"
          attach Generics, "get", Int
        end
      end
    end
    module Android
      module Content
        class Context
        end
        module Pm
          class PackageManager < Jmi::Object
          end
          class ApplicationInfo < Jmi::Object
            attach Java::Lang::CharSequence, "load_description", PackageManager
            attach Java::Lang::String, "to_string"
          end
          class PackageManager < Jmi::Object
            attach Java::Util::List[ApplicationInfo], "get_installed_applications", Int
          end
        end
      end
      module Graphics
        class Typeface < Jmi::Object
          attach_const self, "MONOSPACE"
        end
      end
      module View
        class View < Jmi::Object
          module OnClickListener
          end
          attach_init Android::Content::Context
        end
      end
      module Widget
        class LinearLayout < Android::View::View
          attach_const Int, "HORIZONTAL"
          attach_const Int, "VERTICAL"
          attach Void, ["add_view", "<<"], Android::View::View
          attach Void, "set_orientation", Int
        end
        class TextView < Android::View::View
          attach Void, "set_text", Java::Lang::CharSequence
          attach Void, "set_typeface", Android::Graphics::Typeface
        end
        class Button < Android::View::View
          attach Void, "set_text", Java::Lang::CharSequence
          attach Void, "set_on_click_listener", Android::View::View::OnClickListener
        end
        class Toast < Jmi::Object
          attach_const Int, "LENGTH_SHORT"
          attach_const Int, "LENGTH_LONG"
          attach_static Toast, "make_text", Android::Content::Context, Java::Lang::CharSequence, Int
          attach Void, "show"
        end
        class CheckBox < Android::View::View
          attach Void, "set_checked", Bool
          attach Bool, "is_checked"
          attach Void, "set_text", Java::Lang::CharSequence
          attach Void, "set_on_click_listener", Android::View::View::OnClickListener
        end
        class RadioGroup < LinearLayout
          module OnCheckedChangeListener
          end
          attach Int, "get_checked_radio_button_id"
          attach Void, "set_on_checked_change_listener", Android::Widget::RadioGroup::OnCheckedChangeListener
        end
        class RadioButton < Button
          attach Int, "get_id"
        end
        class EditText < TextView
        end
      end
      module App
        class Activity < Jmi::Object
          attach Void, "set_content_view", Android::View::View
          attach Android::Content::Pm::PackageManager, "get_package_manager"
        end
      end
    end
  end

  class Main < J::Android::App::Activity
    def initialize
      Jmi::Main.main = self
    end
    def exit
      raise SystemExit
    end
    class << self
      attr_accessor :main
      def inherited(main)
        super
        @main = main
      end
    end
  end

  class Listener < Jmi::Object.force_path("com/github/wanabe/Andruboid$Listener")
    @table = []
    attach_init Com::Github::Wanabe::Andruboid,Int
    def initialize(arg = nil, &block)
      block ||= arg
      id = self.class.push block
      super Jmi::Main.main, id
    end
    class << self
      def push(block)
        id = @table.size
        @table.push block
        id
      end
      def call(type, id)
        @table[id].call
      end
    end
  end
end

