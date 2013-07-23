module Jmi
  module J
    module Java
      module Lang
        module Reflect
          class Field < Java::Lang::Object
            def static?
              getModifiers & Modifier::STATIC != 0
            end
            def final?
              getModifiers & Modifier::FINAL != 0
            end
            def public?
              getModifiers & Modifier::PUBLIC != 0
            end
          end
        end
        class << Object
          def inherited(klass)
            super
            klass.attach_auto
          end
          CAMEL2SNAKE_TABLE = []
          "ABCDEFGHIJKLMNOPQRSTUVWXYZ".each_char do |c|
            CAMEL2SNAKE_TABLE.push [c, "_#{c.downcase}"]
          end
          def camel2snake(str)
            str = str.dup
            CAMEL2SNAKE_TABLE.each do |pat|
              str.gsub!(*pat)
            end
            str
          end
          def attach_at(klass, ret, name, *args)
            name, jmethod = super
            type = opt = nil

            rname = camel2snake(name)
            names = []
            names.push rname if rname != name
            argc = args.size
            case argc
            when 0
              case
              when rname.index("get_") == 0
                opt = rname[4..-1]
                names.push opt
                type = :get
              when rname == "to_string"
                names.push "to_s"
              end
            when 1
              case
              when rname.index("set_") == 0
                opt = names.first[4..-1]
                names.push "#{opt}="
                opt = "@#{opt}"
                type = :set
              when rname.index("add_") == 0
                opt = "@#{names.first[4..-1]}"
                type = :add
              end
            end

            case type
            when :set
              klass.define_method(name) do |arg|
                jmethod.call self, name, [arg]
                instance_variable_set opt, arg
              end
            when :add
              klass.define_method(name) do |arg|
                args = [arg]
                jmethod.call self, name, args
                list = instance_variable_get opt
                if list
                  list << arg
                else
                  instance_variable_set opt, args
                end
              end
            end
            names.each do |alias_name|
              klass.alias_method alias_name, name
            end
            names
          end
        end
      end
    end
  end
  module JClass
    def attach_auto
      path = class_path(self, ".")
      klass = Java::Lang::Class.forName(path)
      klass.getDeclaredFields.each do |field|
        type = field.getType
        next if type.is_a? Java::Lang::Class
        next unless field.public? && field.static? && field.final?
        attach_const type, field.getName
      end
    end
  end
  module J::Java::Lang
    Object.attach_auto
    Class.attach_auto
    CharSequence.attach_auto
    String.attach_auto
    Reflect::Modifier.attach_auto
    Reflect::Field.attach_auto
  end
end
