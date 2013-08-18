module Jmi
  module J
    module Java
      module Lang
        module Reflect
          module Member
            def static?
              modifiers & Modifier::STATIC != 0
            end
            def final?
              modifiers & Modifier::FINAL != 0
            end
            def public?
              modifiers & Modifier::PUBLIC != 0
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
            prev = nil
            ary = str.split("_").map do |s|
              if s.length == 1
                if prev
                  prev.concat s
                  nil
                else
                  prev = s
                end
              else
                prev = nil
                s
              end
            end
            ary.compact!
            ary.join("_")
          end
          def attach_at(klass, ret, name, *args)
            super
            attach_alias klass, name, args.size
          end
          def attach_alias(klass, jname, argc)
            name = jname
            rname = camel2snake(name)
            names = []
            if rname != jname
              case
              when argc == 1 && rname.index("set_") == 0
                var_name = rname[4..-1]
                names.push "#{var_name}="
                ivar = "@#{var_name}"
                name = safe_name(rname)
                klass.define_method(name) do |arg|
                  __send__ jname, arg
                  instance_variable_set ivar, arg
                end
              when argc == 1 && rname.index("add_") == 0
                var_name = "@#{rname[4..-1]}"
                name = safe_name(rname)
                klass.define_method(name) do |arg|
                  __send__ jname, arg
                  list = instance_variable_get ivar
                  if list
                    list << arg
                  else
                    instance_variable_set opt, [arg]
                  end
                end
              else
                names.push rname
              end
            end
            case
            when argc == 0 && rname.index("get_") == 0
              names.push rname[4..-1]
            when argc == 0 && rname == "to_string"
              names.push "to_s"
            when argc > 0 && rname == "get"
              names.push "[]"
            end

            names.map! do |alias_name|
              alias_name = safe_name(alias_name)
              klass.alias_method alias_name, name
              alias_name
            end
            names.push name
            names
          end
        end
      end
    end
  end
  module Definition
    def attach_auto
    end
  end
  module J::Java::Lang
    Class.attach_alias Class.singleton_class, "forName", 1
    Class.attach_alias Class, "getDeclaredFields", 0
    Class.attach_alias Class, "getDeclaredMethods", 0
    Reflect::Field.attach_alias Reflect::Field, "getModifiers", 0
    Reflect::Field.attach_alias Reflect::Field, "getName", 0
    Reflect::Field.attach_alias Reflect::Field, "getType", 0
    Reflect::Method.attach_alias Reflect::Method, "getModifiers", 0
    Reflect::Method.attach_alias Reflect::Method, "getName", 0
    Reflect::Method.attach_alias Reflect::Method, "getReturnType", 0
    Reflect::Method.attach_alias Reflect::Method, "getParameterTypes", 0
  end
end
