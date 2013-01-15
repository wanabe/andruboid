#include <jni.h>

#include "mruby.h"
#include "mruby/compile.h"


struct java_ctx {
  JNIEnv* env;
  jobject recv;
};

static mrb_value title(mrb_state* mrb, mrb_value obj) {
  char* str = NULL;
  size_t len;

  mrb_get_args(mrb, "s", &str, &len);
  if (str != NULL && len > 0) {
    struct java_ctx* cx = (struct java_ctx*) mrb->ud;
    jstring jstr = (*cx->env)->NewStringUTF(cx->env, str);
    jclass klass = (*cx->env)->GetObjectClass(cx->env, cx->recv);
    jmethodID mid = (*cx->env)->GetMethodID(cx->env, klass, "title", "(Ljava/lang/String;)V");

    (*cx->env)->CallVoidMethod(cx->env, cx->recv, mid, jstr);
  }
  return mrb_nil_value();
}

void Java_com_github_wanabe_Andruboid_run(JNIEnv* env, jobject recv, jstring jstr) {
  const char* str = (*env)->GetStringUTFChars(env, jstr, NULL);
  struct java_ctx cx = { env, recv };
  struct mrb_state* mrb = mrb_open();

  mrb->ud = &cx;
  mrb_define_method(mrb, mrb->kernel_module, "title", title, ARGS_REQ(1));
  mrb_load_string(mrb, str);
  mrb_close(mrb);
}

#ifndef DISABLE_GEMS
void mrb_init_mrbgems(mrb_state *mrb) {
}
#endif
