module Jmi
  module J
    module Android
      module Util
        class Log < Java::Lang::Object
          attach_static Int, "v", Java::Lang::String, Java::Lang::String
        end
        class AttributeSet < Java::Lang::Object
        end
      end

      module ::Kernel
        def p(*objs)
          objs.each do |obj|
            Jmi::J::Android::Util::Log.v("stdout", obj.inspect)
          end
        end
      end

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
      module Graphics
        class Typeface < Java::Lang::Object
          attach_const self, "MONOSPACE"
        end
        module Drawable
          class Drawable < Java::Lang::Object
          end
        end
        class Color < Java::Lang::Object
          attach_static Int, "argb", Int, Int, Int, Int
        end
        class Paint < Java::Lang::Object
          class Style < Java::Lang::Object
            attach_const self, "FILL"
            attach_const self, "STROKE"
            attach_const self, "FILL_AND_STROKE"
          end
          attach_auto
          attach_init
          attach Void, "setColor", Int
          attach Void, "setAntiAlias", Boolean
          attach Void, "setStyle", Style
        end
        class Region < Java::Lang::Object
          class Op < Java::Lang::Object
            attach_const self, "DIFFERENCE"
          end
        end
        class RectF < Java::Lang::Object
          attach_init Float, Float, Float, Float
        end
        class Path < Java::Lang::Object
          class Direction < Java::Lang::Object
            attach_const self, "CW"
          end
          attach_auto
          attach_init
          attach Void, "addCircle", Float, Float, Float, Direction
          attach Void, "addRoundRect", RectF, Float, Float, Direction
          attach Void, "addRect", RectF, Direction
          attach Void, "addArc", RectF, Float, Float
          attach Void, "moveTo", Float, Float
          attach Void, "lineTo", Float, Float
        end
        class Canvas < Java::Lang::Object
          attach Void, "drawPoint", Float, Float, Paint
          attach Void, "drawPoints", [Float], Paint
          attach Void, "drawLine", Float, Float, Float, Float, Paint
          attach Void, "drawLines", [Float], Paint
          attach Void, "drawARGB", Int, Int, Int, Int
          attach Boolean, "clipPath", Path, Region::Op
          attach Void, "drawPath", Path, Paint
          attach Void, "drawRect", RectF, Paint
          attach Void, "drawRect", Float, Float, Float, Float, Paint
          attach Void, "drawCircle", Float, Float, Float, Paint
          attach Void, "drawOval", RectF, Paint
          attach Void, "drawArc", RectF, Float, Float, Boolean, Paint
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
        class DialogInterface < Java::Lang::Object
          module OnClickListener
            extend Interface
          end
          attach_const Int, "BUTTON_NEGATIVE"
          attach_const Int, "BUTTON_NEUTRAL"
          attach_const Int, "BUTTON_POSITIVE"
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
          attach_auto
          attach_const Int, "LAYER_TYPE_SOFTWARE"
          attach Void, "setLayoutParams", ViewGroup::LayoutParams
          attach Void, "setOnClickListener", OnClickListener
          attach Void, "setLayerType", Int, Graphics::Paint
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
          attach_auto
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
          attach_auto
          attach Void, "setOnItemClickListener", OnItemClickListener
          attach Java::Lang::Object, "getItemAtPosition", Int
          alias [] getItemAtPosition
        end
        class AbsListView < AdapterView
          module OnScrollListener
            extend Interface
          end
          attach_auto
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
        class ProgressBar < Android::View::View
          attach_init Android::Content::Context
          attach_init Android::Content::Context, Android::Util::AttributeSet, Int
          attach Void, "setMax", Int
          attach Void, "setProgress", Int
          attach Void, "setProgressDrawable", Android::Graphics::Drawable::Drawable
        end
        class AbsSeekBar < ProgressBar
          attach Void, "setMax", Int
        end
        class RatingBar < AbsSeekBar
          attach_init Android::Content::Context
          attach Void, "setNumStars", Int
          attach Void, "setRating", Float
        end
        class SeekBar < AbsSeekBar
          attach_init Android::Content::Context
          attach Void, "setProgress", Int
        end
        class AnalogClock < Android::View::View
          attach_init Android::Content::Context
        end
        class DigitalClock < Android::View::View
          attach_init Android::Content::Context
        end
        class Chronometer < Android::View::View
          attach_init Android::Content::Context
          attach Void, "start"
          attach Void, "stop"
          attach Void, "setFormat", Java::Lang::String
        end
      end
      module App
        class Activity < Content::Context
          attach Void, "setContentView", Android::View::View
          attach Android::Content::Pm::PackageManager, "getPackageManager"
          attach Void, "finish"
        end
        class Dialog < Java::Lang::Object
          attach Void, "show"
          attach Void, "setCancelable", Boolean
        end
        class AlertDialog < Dialog
          class Builder < Java::Lang::Object
            attach_init Content::Context
            attach AlertDialog, "create"
            attach self, "setTitle", Java::Lang::CharSequence
            attach self, "setMessage", Java::Lang::CharSequence
            attach self, "setPositiveButton", Java::Lang::CharSequence, Content::DialogInterface::OnClickListener
            attach self, "setNegativeButton", Java::Lang::CharSequence, Content::DialogInterface::OnClickListener
            attach self, "setNeutralButton", Java::Lang::CharSequence, Content::DialogInterface::OnClickListener
          end
          attach Void, "setTitle", Java::Lang::CharSequence
        end
        class ProgressDialog < AlertDialog
          attach_const Int, "STYLE_HORIZONTAL"
          attach_init Content::Context
          attach Void, "setMessage", Java::Lang::CharSequence
          attach Void, "setIndeterminate", Boolean
          attach Void, "setProgressStyle", Int
          attach Void, "setMax", Int
          attach Void, "incrementProgressBy", Int
          attach Void, "incrementSecondaryProgressBy", Int
        end
        class DatePickerDialog < AlertDialog
          module OnDateSetListener
            extend Interface
          end
          attach_init Content::Context, OnDateSetListener, Int, Int, Int
        end
        class TimePickerDialog < AlertDialog
          module OnTimeSetListener
            extend Interface
          end
          attach_init Content::Context, OnTimeSetListener, Int, Int, Boolean
        end
      end
    end
    module Com
      module Github
        module Wanabe
          class Andruboid < Android::App::Activity
            class Listener < Jmi::Object
              include Android::App::DatePickerDialog::OnDateSetListener
              include Android::App::TimePickerDialog::OnTimeSetListener
              include Android::View::View::OnClickListener
              include Android::Widget::AdapterView::OnItemClickListener
              include Android::Widget::AdapterView::OnItemSelectedListener
              include Android::Widget::AbsListView::OnScrollListener
              include Android::Content::DialogInterface::OnClickListener

              @table = []
              attach_const Int, "ON_CLICK"
              attach_const Int, "ON_CHECKED_CHANGE"
              attach_const Int, "ON_ITEM_CLICK"
              attach_const Int, "ON_ITEM_SELECTED"
              attach_const Int, "ON_NOTHING_SELECTED"
              attach_const Int, "ON_SCROLL"
              attach_const Int, "ON_SCROLL_STATE_CHANGED"

              attach_init Com::Github::Wanabe::Andruboid, Int
              def initialize(*types, &block)
                @types = types
                @block = block
                id = self.class.push self
                super Jmi::Main.main, id
              end
              def call(type, opt)
                return unless @types.empty? || @types.include?(type)
                args = opt.is_a?(Array) ? opt : [opt]
                args.unshift type if @types.size > 1
                @block.call *args
              end
              class << self
                def push(listener)
                  id = @table.size
                  @table.push listener
                  id
                end
                def call(type, id, opt)
                  @table[id].call(type, opt)
                end
              end
            end
            class CustomView < Android::View::View
              attach_init Andruboid
              attach Void, "setOnDraw", Listener
            end
          end
        end
      end
    end
  end

  Main = J::Com::Github::Wanabe::Andruboid
  Listener = Main::Listener
  CustomView = Main::CustomView
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
