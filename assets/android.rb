module Jmi
  module J
    module Android
      class R
        class Layout < Java::Lang::Object.force_path("android/R$layout")
          attach_const Int, "simple_list_item_1"
        end
      end
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
        end
        class ViewGroup < View
          class LayoutParams < Java::Lang::Object
            attach_init Int, Int
            attach_const Int, "WRAP_CONTENT"
            attach_const Int, "MATCH_PARENT"
          end
          attach Void, "addView", Android::View::View
          attach Void, "addView", Android::View::View, LayoutParams
          alias << addView
          attach Void, "removeAllViews"
          alias remove_all remove_all_views
        end
        class View
          attach Void, "setLayoutParams", ViewGroup::LayoutParams
        end
      end
      module Widget
        class LinearLayout < Android::View::ViewGroup
          class LayoutParams < Android::View::ViewGroup::LayoutParams
            attach_init Int, Int, Float
            attach_init Int, Int
            attach Java::Lang::String, "debug", Java::Lang::String
          end
          attach_const Int, "VERTICAL"
          attach_init Android::Content::Context
          attach Void, "setOrientation", Int
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
            extend Interface
          end
          attach_init Android::Content::Context
          attach Int, "getCheckedRadioButtonId"
          attach Void, "setOnCheckedChangeListener", OnCheckedChangeListener
        end
        class RadioButton < Button
          attach_init Android::Content::Context
          attach Int, "getId"
        end
        class EditText < TextView
          attach_init Android::Content::Context
        end
        module ListAdapter
          extend Interface
        end
        class ArrayAdapter < Java::Lang::Object
          extend Generics
          include ListAdapter
          attach_init Content::Context, Int
          attach Void, "add", Generics
          attach Generics, "getItem", Int
          def [](index)
            get_item index
          end
        end
        class AdapterView < Android::View::View
          module OnItemClickListener
            extend Interface
          end
          attach Void, "setOnItemClickListener", OnItemClickListener
          attach Java::Lang::Object, "getItemAtPosition", Int
          alias [] getItemAtPosition
        end
        class AbsListView < AdapterView
          module OnScrollListener
            extend Interface
          end
          attach Void, "setOnScrollListener", OnScrollListener
        end
        class ListView < AbsListView
          attach_init Android::Content::Context
          attach Void, "setAdapter", ListAdapter
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
              include Android::Widget::AdapterView::OnItemClickListener
              include Android::Widget::AbsListView::OnScrollListener
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
                def call(type, id, opt)
                  @table[id].call(opt)
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

