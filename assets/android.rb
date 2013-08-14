module Jmi
  module J
    module Android
      module Os
        class Process < Java::Lang::Object
          attach_static Void, "killProcess", Int
          attach_static Int, "myPid"
        end
      end
      class R
        class Layout < Java::Lang::Object.force_path("android/R$layout")
          attach_const Int, "simple_list_item_1"
          attach_const Int, "simple_spinner_item"
          attach_const Int, "simple_spinner_dropdown_item"
        end
        class Style < Java::Lang::Object.force_path("android/R$style")
          attach_const Int, "Widget_ProgressBar_Horizontal"
        end
        class Drawable < Java::Lang::Object.force_path("android/R$drawable")
          attach_const Int, "progress_horizontal"
        end
      end
      module Util
        class Log < Java::Lang::Object
          attach_static Int, "v", Java::Lang::String, Java::Lang::String
        end
        class AttributeSet < Java::Lang::Object
        end
      end
      module Graphics
        class Typeface < Java::Lang::Object
          attach_const self, "MONOSPACE"
        end
        module Drawable
          class Drawable < Java::Lang::Object
          end
        end
      end
      module Content
        class Context < Java::Lang::Object
        end
        module Res
          class Resources < Java::Lang::Object
            attach_static self, "getSystem"
            attach Android::Graphics::Drawable::Drawable, "getDrawable", Int
          end
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
          attach_const Int, "HORIZONTAL"
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
        module SpinnerAdapter
          extend Interface
        end
        class ArrayAdapter < Java::Lang::Object
          extend Generics
          include ListAdapter
          include SpinnerAdapter
          attach_init Content::Context, Int
          attach Void, "add", Generics
          attach Generics, "getItem", Int
          attach Void, "setDropDownViewResource", Int
          def [](index)
            get_item index
          end
        end
        class AdapterView < Android::View::View
          module OnItemClickListener
            extend Interface
          end
          module OnItemSelectedListener
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
        class Spinner < AdapterView
          attach_init Android::Content::Context
          attach Void, "setAdapter", SpinnerAdapter
          attach Void, "setOnItemSelectedListener", AdapterView::OnItemSelectedListener
        end
        class RatingBar < Android::View::View
          attach_init Android::Content::Context
          attach Void, "setNumStars", Int
          attach Void, "setRating", Float
        end
        class SeekBar < Android::View::View
          attach_init Android::Content::Context
          attach Void, "setMax", Int
          attach Void, "setProgress", Int
        end
        class ProgressBar < Android::View::View
          attach_init Android::Content::Context
          attach_init Android::Content::Context, Android::Util::AttributeSet, Int
          attach Void, "setMax", Int
          attach Void, "setProgress", Int
          attach Void, "setProgressDrawable", Android::Graphics::Drawable::Drawable
        end
      end
      module App
        class Activity < Content::Context
          attach Void, "setContentView", Android::View::View
          attach Android::Content::Pm::PackageManager, "getPackageManager"
          attach Void, "finish"
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
              include Android::Widget::AdapterView::OnItemSelectedListener
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
      finish
      Android::Os::Process.kill_process Android::Os::Process.my_pid
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

module Kernel
  def p(*objs)
    objs.each do |obj|
      Jmi::J::Android::Util::Log.v("print", obj.inspect)
    end
  end
end
