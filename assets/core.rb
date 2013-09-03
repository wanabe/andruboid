module Jni
  module J
    module Java
      module Lang
        class Object < Jni::Object
        end
        class Class < Java::Lang::Object
          J::TYPE_TABLE[self] = "c"
          class << self
            def attach(ret, name, *args)
              classclass = self
              names = super
              names = [name] if names.is_a?(Proc) || names.is_a?(Symbol)
              names.each do |name|
                Jni::Object.singleton_class.define_method(safe_name(name, Jni::Object.singleton_class)) do |*argv|
                  @jclassobj.send(name, *argv)
                end
              end
            end
          end
        end
        class CharSequence < Java::Lang::Object
          as_string
        end
        class String < CharSequence
        end
        module Reflect
          module Member
            extend Interface
          end
          class Modifier < Java::Lang::Object
            attach_const Int, "STATIC"
            attach_const Int, "FINAL"
            attach_const Int, "PUBLIC"
          end
          class Field < Java::Lang::Object
            include Member
            attach Int, "getModifiers"
            attach Java::Lang::String, "getName"
            attach Java::Lang::Class, "getType"
          end
          class Method < Java::Lang::Object
            include Member
            attach Int, "getModifiers"
            attach Java::Lang::String, "getName"
            attach Java::Lang::Class, "getReturnType"
            attach [Java::Lang::Class], "getParameterTypes"
          end
        end
        class Class < Java::Lang::Object
          attach_static Class, "forName", String
          attach [Reflect::Field], "getDeclaredFields"
          attach [Reflect::Method], "getDeclaredMethods"
          attach String, "getName"
        end
      end
    end
  end
end
