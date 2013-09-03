module Jni
  module J
    module Android
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
    end
  end
end
