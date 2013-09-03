module Jni
  module J
    module Android
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
    end
  end
end
