module Jni
  module J
    module Android
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
  end
end
