module Jmi
  module J
    module Android
      module Content
        class Context < Java::Lang::Object
        end
        module Pm
          class PackageManager < Java::Lang::Object
          end
          class ApplicationInfo < Java::Lang::Object
            attach Java::Lang::CharSequence, "loadDescription", PackageManager
            attach Java::Lang::String, "toString"
          end
          class PackageManager < Java::Lang::Object
            attach Java::Util::List[ApplicationInfo], "getInstalledApplications", Int
          end
        end
      end
      module Graphics
        class Typeface < Java::Lang::Object
          attach_const self, "MONOSPACE"
        end
      end
      module View
        class View < Java::Lang::Object
          module OnClickListener
            extend Interface
          end
          attach_auto
        end
        class ViewGroup < View
        end
      end
      module Widget
        class LinearLayout < Android::View::ViewGroup
          attach_const Int, "VERTICAL"
          attach_init Android::Content::Context
          attach Void, "addView", Android::View::View
          attach Void, "setOrientation", Int
          alias << addView
        end
        class TextView < Android::View::View
          attach_init Android::Content::Context
          attach Void, "setText", Int
          attach Void, "setText", Java::Lang::CharSequence
          attach Void, "setTypeface", Android::Graphics::Typeface
        end
        class Button < TextView
          attach_init Android::Content::Context
          attach Void, "setOnClickListener", Android::View::View::OnClickListener
        end
        class Toast < Java::Lang::Object
          attach_const Int, "LENGTH_LONG"
          attach_const Int, "LENGTH_SHORT"
          attach_static Toast, "makeText", Android::Content::Context, Java::Lang::CharSequence, Int
          attach Void, "show"
        end
        class CompoundButton < Button
        end
        class CheckBox < CompoundButton
          attach_init Android::Content::Context
          attach Void, "setChecked", Boolean
          attach Boolean, "isChecked"
          attach Void, "setText", Java::Lang::CharSequence
          attach Void, "setOnClickListener", Android::View::View::OnClickListener
        end
        class RadioGroup < LinearLayout
          module OnCheckedChangeListener
          end
          attach_init Android::Content::Context
          attach Int, "getCheckedRadioButtonId"
          attach Void, "setOnCheckedChangeListener", Android::Widget::RadioGroup::OnCheckedChangeListener
        end
        class RadioButton < Button
          attach_init Android::Content::Context
          attach Int, "getId"
        end
        class EditText < TextView
          attach_init Android::Content::Context
        end
      end
      module App
        class Activity < Content::Context
          attach Void, "setContentView", Android::View::View
          attach Android::Content::Pm::PackageManager, "getPackageManager"
        end
      end
    end
    module Com
      module Github
        module Wanabe
          class Andruboid < Android::App::Activity
            class Listener < Jmi::Object
              include Android::View::View::OnClickListener
              @table = []
              attach_init Com::Github::Wanabe::Andruboid, Int
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
        end
      end
    end
  end

  Main = J::Com::Github::Wanabe::Andruboid
  Listener = Main::Listener
  class Main
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
end

