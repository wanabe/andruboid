module Jmi
  module J
    module Java
      module Lang
        class Object < Jmi::Object
        end
        class Class < Java::Lang::Object
          J::TYPE_TABLE[self] = "c"
          class << self
            def attach(ret, names, *args)
              classclass = self
              names = super
              names.pop unless names.last.is_a? ::String
              names.each do |name|
                Jmi::Object.singleton_class.define_method(name) do |*argv|
                  @jclassobj.send(name, *argv)
                end
              end
            end
          end
        end
        class CharSequence < Java::Lang::Object
          include AsString
        end
        class String < CharSequence
        end
        module Reflect
          class Modifier < Java::Lang::Object
            attach_const Int, "STATIC"
            attach_const Int, "FINAL"
            attach_const Int, "PUBLIC"
          end
          class Field < Java::Lang::Object
            attach Int, "getModifiers"
            attach Java::Lang::String, "getName"
            attach Java::Lang::Class, "getType"
          end
        end
        class Class < Java::Lang::Object
          attach_static Class, "forName", String
          attach [Reflect::Field], "getDeclaredFields"
        end
      end
    end
  end
end
