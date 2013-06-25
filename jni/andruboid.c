#include <jni.h>
#include <stdio.h>
#include <errno.h>

#include "mruby-all.h"

static void
jobj_free(mrb_state *mrb, void *p)
{
  JNIEnv* env = (JNIEnv*)mrb->ud;
  (*env)->DeleteGlobalRef(env, (jobject)p);
}

static const struct mrb_data_type jobj_data_type = {
  "jobject", jobj_free, 
};

static mrb_value jobj__initialize(mrb_state *mrb, mrb_value self) {
  char *cpath, *csig;
  jclass jclass;
  jmethodID jmeth;
  jobject jobj, jarg;
  JNIEnv* env = (JNIEnv*)mrb->ud;
  mrb_value mobj, mstr, mclass = mrb_obj_value(mrb_obj_class(mrb, self));

  mrb_get_args(mrb, "o", &mobj); // TODO
  jarg = DATA_PTR(mobj);
  mstr = mrb_iv_get(mrb, mclass, mrb_intern_cstr(mrb, "@class_path"));
  cpath = mrb_string_value_cstr(mrb, &mstr);
  mstr = mrb_iv_get(mrb, mclass, mrb_intern_cstr(mrb, "@init_sig"));
  csig = mrb_string_value_cstr(mrb, &mstr);

  jclass = (*env)->FindClass(env, cpath);
  jmeth = (*env)->GetMethodID(env, jclass, "<init>", csig);
  jobj = (*env)->NewObject(env, jclass, jmeth, jarg);
  DATA_PTR(self) = (*env)->NewGlobalRef(env, jobj);
  
  (*env)->DeleteLocalRef(env, jobj);
  (*env)->DeleteLocalRef(env, jclass);
  return self;
}

static mrb_value main__new(mrb_state *mrb, struct RClass *klass, jobject jact) {
  mrb_value mobj;
  JNIEnv* env = (JNIEnv*)mrb->ud;

  jact = (*env)->NewGlobalRef(env, jact);
  mobj = mrb_obj_value(Data_Wrap_Struct(mrb, klass, &jobj_data_type, (void*)jact));
  mrb_funcall(mrb, mobj, "initialize", 0);
  return mobj;
}

static mrb_value jmain__initialize(mrb_state *mrb, mrb_value self) {
}


static mrb_value jmeth__call(mrb_state *mrb, mrb_value self) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  mrb_value mobj, marg, mstr;
  char *cname, *csig;
  jobject jthis;
  jclass jclazz;
  jmethodID jmeth;
  jobject jobj;

  mrb_get_args(mrb, "oo", &mobj, &marg); // TODO
  jthis = (jobject)DATA_PTR(mobj);
  mrb_gv_set(mrb, mrb_intern_cstr(mrb, "$qq"), mobj);
  jclazz = (*env)->GetObjectClass(env, jthis);

  mstr = mrb_iv_get(mrb, self, mrb_intern_cstr(mrb, "@name"));
  cname = mrb_sym2name(mrb, mrb_symbol(mstr));
  mstr = mrb_iv_get(mrb, self, mrb_intern_cstr(mrb, "@sig"));
  csig = mrb_string_value_cstr(mrb, &mstr);
  jmeth =  (*env)->GetMethodID(env, jclazz, cname, csig);

  if (csig[2] != 'a') { //TODO
    jobj = (jobject)(*env)->NewStringUTF(env, mrb_string_value_cstr(mrb, &marg));
  } else {
    jobj = (jobject)DATA_PTR(marg);
  }
  (*env)->CallVoidMethod(env, (jobject)DATA_PTR(mobj), jmeth, jobj);

  if (csig[2] != 'a') { //TODO
    (*env)->DeleteLocalRef(env, jobj);
  }
  (*env)->DeleteLocalRef(env, jclazz);
  return self;
}

static void init_jmi(mrb_state *mrb) {
  struct RClass *klass;
  klass = mrb_define_class(mrb, 
    "JavaObject", mrb->object_class);
  MRB_SET_INSTANCE_TT(klass, MRB_TT_DATA);
  mrb_define_method(mrb, klass, "initialize", jobj__initialize, ARGS_REQ(1));

  klass = mrb_define_class(mrb, 
    "JavaMain", klass);
  MRB_SET_INSTANCE_TT(klass, MRB_TT_DATA);
  mrb_define_method(mrb, klass, "initialize", jmain__initialize, ARGS_NONE());

  klass = mrb_define_class(mrb, 
    "JavaMethod", mrb->object_class);
  MRB_SET_INSTANCE_TT(klass, MRB_TT_DATA);
  mrb_define_method(mrb, klass, "call", jmeth__call, ARGS_REST());
}

static void load_init_script(mrb_state *mrb, JNIEnv* env, jobject jact, jobjectArray scrs) {
  FILE *fp;
  mrb_value mobj, mstr, mclass, mmain_class;
  jstring scr;
  jshort len;
  int i;

  mrb->ud = (void*)env;
  init_jmi(mrb);

  len = (*env)->GetArrayLength(env, scrs);
  for(i = 0; i < len; i++) {
    scr = (*env)->GetObjectArrayElement(env, scrs, i);
    mstr = mrb_load_string(mrb, (*env)->GetStringUTFChars(env, scr, NULL));
    if (mrb->exc) {
      return;
    }
  }

  mmain_class = mrb_obj_value(mrb_class_get(mrb, "JavaMain"));
  mclass = mrb_iv_get(mrb, mmain_class, mrb_intern_cstr(mrb, "@main"));
  mobj = main__new(mrb, mrb_class_ptr(mclass), jact);

  if (mrb->exc) {
    return;
  }
  mrb_iv_set(mrb, mmain_class, mrb_intern_cstr(mrb, "@main"), mobj);
}

void Java_com_github_wanabe_Andruboid_initialize(JNIEnv* env, jobject thiz, jobjectArray scrs) {
  mrb_state *mrb = mrb_open();

  load_init_script(mrb, env, thiz, scrs);
}

