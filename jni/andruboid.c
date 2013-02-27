#include <jni.h>

#include "mruby.h"
#include "mruby/compile.h"
#include "mruby/string.h"
#include "mruby/proc.h"

struct java_ctx {
  JNIEnv* env;
  jobject recv;
  jclass klass;
};

extern char app[];

static mrb_value printstr(mrb_state* mrb, mrb_value obj) {
  char* str = NULL;
  size_t len;

  mrb_get_args(mrb, "s", &str, &len);
  if (str != NULL && len > 0) {
    struct java_ctx* cx = (struct java_ctx*) mrb->ud;
    jstring jstr = (*cx->env)->NewStringUTF(cx->env, str);
    jmethodID mid = (*cx->env)->GetMethodID(cx->env, cx->klass, "print", "(Ljava/lang/String;)V");

    (*cx->env)->CallVoidMethod(cx->env, cx->recv, mid, jstr);

    (*cx->env)->DeleteLocalRef(cx->env, jstr);
  }
  return mrb_nil_value();
}

void Java_com_github_wanabe_Andruboid_run(JNIEnv* env, jobject recv) {
  struct java_ctx cx = { env, recv };
  struct mrb_state* mrb = mrb_open();
  int n = mrb_read_irep(mrb, app);

  cx.klass = (*env)->GetObjectClass(env, recv);
  mrb->ud = &cx;
  mrb_define_method(mrb, mrb->kernel_module, "__printstr__", printstr, ARGS_REQ(1));
  mrb_run(mrb, mrb_proc_new(mrb, mrb->irep[n]), mrb_top_self(mrb));
  if (mrb->exc) {
    mrb_value msg = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
    struct java_ctx* cx = (struct java_ctx*) mrb->ud;
    jstring jstr = (*cx->env)->NewStringUTF(cx->env, RSTRING_PTR(msg));
    jmethodID mid = (*cx->env)->GetMethodID(cx->env, cx->klass, "alert", "(Ljava/lang/String;)V");

    (*cx->env)->CallVoidMethod(cx->env, cx->recv, mid, jstr);
    mrb->exc = 0;
  }
  mrb_close(mrb);
}

#ifndef DISABLE_GEMS
void mrb_init_mrbgems(mrb_state *mrb) {
}
#endif
