#include <jni.h>

#include "mruby.h"
#include "mruby/compile.h"
#include "mruby/string.h"
#include "mruby/proc.h"

struct java_ctx {
  JNIEnv* env;
  jobject recv;
};

extern char app[];

void Java_com_github_wanabe_Andruboid_run(JNIEnv* env, jobject recv) {
  struct java_ctx cx = { env, recv };
  struct mrb_state* mrb = mrb_open();
  int n = mrb_read_irep(mrb, app);

  mrb->ud = &cx;
  mrb_run(mrb, mrb_proc_new(mrb, mrb->irep[n]), mrb_top_self(mrb));
  if (mrb->exc) {
    mrb_value msg = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
    struct java_ctx* cx = (struct java_ctx*) mrb->ud;
    jstring jstr = (*cx->env)->NewStringUTF(cx->env, RSTRING_PTR(msg));
    jclass klass = (*cx->env)->GetObjectClass(cx->env, cx->recv);
    jmethodID mid = (*cx->env)->GetMethodID(cx->env, klass, "alert", "(Ljava/lang/String;)V");

    (*cx->env)->CallVoidMethod(cx->env, cx->recv, mid, jstr);
    mrb->exc = 0;
  }
  mrb_close(mrb);
}

#ifndef DISABLE_GEMS
void mrb_init_mrbgems(mrb_state *mrb) {
}
#endif
