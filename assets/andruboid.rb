module Jni
  module J
    module Com
      module Github
        module Wanabe
          class Andruboid < Android::App::Activity
            class Listener < Jni::Object
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
                super Jni::Main.main, id
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
      Jni::Main.main = self
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
