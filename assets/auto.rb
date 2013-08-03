module Jmi
  module Definition
    def attach(*args)
    end
    def attach_auto
      path = class_path(self, ".")
      klass = Java::Lang::Class.for_name(path)
      klass.getDeclaredFields.each do |field|
        type = field.type
        next if type.is_a? Java::Lang::Class
        next unless field.public? && field.static? && field.final?
        attach_const type, field.name
      end

      getDeclaredMethods.each do |meth|
        next if meth.static?
        types = [meth.return_type, *meth.parameter_types]
        next if types.any? do |type|
          type.is_a? Java::Lang::Class
        end
        ret = types.shift
        n = attach_at self, ret, meth.name, *types
      end
    end
  end
  module J
    module Java
      module Lang
        class << Class
          def attach(*args)
          end
        end
      end
    end
  end
  module J::Java::Lang
    [
      Object, Class, CharSequence, String,
      Reflect::Modifier, Reflect::Field, Reflect::Method
    ].each do |klass|
      klass.attach_auto
    end
  end
end

