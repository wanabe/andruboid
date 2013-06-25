Dir.chdir("mruby/include")
buf = ""
(["mruby.h"] + Dir.glob("mruby/*.h")).each do |name|
  buf.concat "#include \"#{name}\"\n"
end
Dir.chdir("../..")

table = {}
tail = 0
nil while buf.sub!(/[ \t]*#[ \t]*include "([^"]+)"$/) do
  if table[$1]
    ""
  else
    table[$1] = true
    open("mruby/include/#{$1}") do |f|
      f.read
    end
  end
end
open("jni/mruby-all.h", "w") do |f|
  f.print buf
end
