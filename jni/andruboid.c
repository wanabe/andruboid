#include <jni.h>
#include <stdio.h>
#include <errno.h>

#include "mruby-all.h"

char err[1024] = {0};

static void jobj_free(mrb_state *mrb, void *p) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  (*env)->DeleteGlobalRef(env, (jobject)p);
}

static const struct mrb_data_type jobj_data_type = {
  "jobject", jobj_free, 
};

static mrb_value jobj_s__set_class_path(mrb_state *mrb, mrb_value self) {
  mrb_value mobj, mpath;
  char *cpath;
  jclass jclazz, jglobal;
  JNIEnv* env = (JNIEnv*)mrb->ud;

  mrb_get_args(mrb, "o", &mpath);
  cpath = mrb_string_value_cstr(mrb, &mpath);
  jclazz = (*env)->FindClass(env, cpath);
  if ((*env)->ExceptionCheck(env)) {
    (*env)->ExceptionClear(env);
    mrb_raisef(mrb, E_NAME_ERROR, "Jmi: can't get %S", mpath);
  }

  jglobal = (*env)->NewGlobalRef(env, jclazz);
  mobj = mrb_obj_value(Data_Wrap_Struct(mrb, mrb->object_class, &jobj_data_type, (void*)jglobal));
  mrb_iv_set(mrb, self, mrb_intern_cstr(mrb, "jclass"), mobj);

  (*env)->DeleteLocalRef(env, jclazz);
  return mpath;
}

static mrb_value wrap_jobject(mrb_state *mrb, struct RClass *klass, jobject jobj) {
  mrb_value mobj;
  JNIEnv* env = (JNIEnv*)mrb->ud;

  jobj = (*env)->NewGlobalRef(env, jobj);
  mobj = mrb_obj_value(Data_Wrap_Struct(mrb, klass, &jobj_data_type, (void*)jobj));
  mrb_funcall(mrb, mobj, "initialize", 0);
  return mobj;
}

struct RJMethod {
  jmethodID id;
  int type; // TODO
};

static void jmeth_free(mrb_state *mrb, void *p) {
  free(p);
}

static const struct mrb_data_type jmeth_data_type = {
  "jmethod", jmeth_free, 
};

static mrb_value jmeth__initialize(mrb_state *mrb, mrb_value self) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  mrb_value mclass, mname, msig;
  jclass jclazz;
  jmethodID jmeth;
  char *cname, *csig;
  struct RJMethod *smeth = (struct RJMethod *)malloc(sizeof(struct RJMethod));

  mrb_get_args(mrb, "ooo", &mclass, &mname, &msig);
  mclass = mrb_iv_get(mrb, mclass, mrb_intern_cstr(mrb, "jclass"));
  jclazz = DATA_PTR(mclass);
  cname = mrb_string_value_cstr(mrb, &mname);

  csig = mrb_string_value_cstr(mrb, &msig);
  jmeth = (*env)->GetMethodID(env, jclazz, cname, csig);
  if ((*env)->ExceptionCheck(env)) {
    (*env)->ExceptionClear(env);
    mrb_raisef(mrb, E_NAME_ERROR, "Jmi: can't get %S%S", mname, msig);
  }

  smeth->id = jmeth;
  smeth->type = cname[0] == '<' ? 2 : csig[2] != 'a' ? 1 : 0; // TODO
  DATA_TYPE(self) = &jmeth_data_type;
  DATA_PTR(self) = smeth;

  return self;
}

static mrb_value jmeth__call(mrb_state *mrb, mrb_value self) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  mrb_value mobj, mname, marg;
  struct RJMethod *smeth;
  jobject jobj;

  mrb_get_args(mrb, "ooo", &mobj, &mname, &marg); // TODO

  smeth = DATA_PTR(self);

  switch (smeth->type) { //TODO
    case 2: {
      jclass jclazz;
      mrb_value mclass = mrb_obj_value(mrb_obj_class(mrb, mobj));
      mclass = mrb_iv_get(mrb, mclass, mrb_intern_cstr(mrb, "jclass"));
      jclazz = DATA_PTR(mclass);
      jobj = (jobject)DATA_PTR(marg);
      jobj = (*env)->NewObject(env, jclazz, smeth->id, jobj);
      DATA_PTR(mobj) = (*env)->NewGlobalRef(env, jobj);
      (*env)->DeleteLocalRef(env, jobj);
    } break;
    case 1: {
      jobj = (jobject)(*env)->NewStringUTF(env, mrb_string_value_cstr(mrb, &marg));
      (*env)->CallVoidMethod(env, (jobject)DATA_PTR(mobj), smeth->id, jobj);
      (*env)->DeleteLocalRef(env, jobj);
    } break;
    case 0: {
      jobj = (jobject)DATA_PTR(marg);
      (*env)->CallVoidMethod(env, (jobject)DATA_PTR(mobj), smeth->id, jobj);
    } break;
  }
  if ((*env)->ExceptionCheck(env)) {
    (*env)->ExceptionClear(env);
    mrb_raisef(mrb, E_RUNTIME_ERROR, "Jmi: exception in %S", mname);
  }
  return self;
}

static struct RClass *init_jmi(mrb_state *mrb) {
  struct RClass *klass, *mod;
  mod = mrb_define_module(mrb, "Jmi");

  klass = mrb_define_class_under(mrb, mod,
    "Method", mrb->object_class);
  MRB_SET_INSTANCE_TT(klass, MRB_TT_DATA);
  mrb_define_method(mrb, klass, "initialize", jmeth__initialize, ARGS_REQ(3));
  mrb_define_method(mrb, klass, "call", jmeth__call, ARGS_REST());

  klass = mrb_define_class_under(mrb, mod,
    "Object", mrb->object_class);
  MRB_SET_INSTANCE_TT(klass, MRB_TT_DATA);
  mrb_define_singleton_method(mrb, (struct RObject *)klass, "class_path=", jobj_s__set_class_path, ARGS_REQ(1));

  return mod;
}

static int check_exc(mrb_state *mrb) {
  JNIEnv* env = (JNIEnv*)mrb->ud;

  if (mrb->exc) {
    mrb_value mstr = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
    jclass jclazz = (*env)->FindClass(env, "java/lang/RuntimeException");
    if (jclazz) {
      (*env)->ThrowNew(env, jclazz, mrb_string_value_cstr(mrb, &mstr));
      (*env)->DeleteLocalRef(env, jclazz);
    }
    return 1;
  }
  return 0;
}

jint Java_com_github_wanabe_Andruboid_initialize(JNIEnv* env, jobject thiz) {
  mrb_state *mrb = mrb_open();

  mrb->ud = (void*)env;
  init_jmi(mrb);
  
  return (jint)mrb;
}

void Java_com_github_wanabe_Andruboid_evalScript(JNIEnv* env, jobject thiz, jint jmrb, jstring scr) {
  mrb_state *mrb = (mrb_state *)jmrb;

  mrb_load_string(mrb, (*env)->GetStringUTFChars(env, scr, NULL));
  check_exc(mrb);
}

void Java_com_github_wanabe_Andruboid_run(JNIEnv* env, jobject thiz, jint jmrb) {
  mrb_state *mrb = (mrb_state *)jmrb;
  struct RClass *klass, *mod = mrb_class_get(mrb, "Jmi");
  mrb_value mmain_class, mclass, mobj;

  mmain_class = mrb_const_get(mrb, mrb_obj_value(mod), mrb_intern_cstr(mrb, "Main"));
  klass = mrb_class_ptr(mmain_class);
  MRB_SET_INSTANCE_TT(klass, MRB_TT_DATA);
  if (check_exc(mrb)) {
    return;
  }

  mclass = mrb_iv_get(mrb, mmain_class, mrb_intern_cstr(mrb, "@main"));
  mobj = wrap_jobject(mrb, mrb_class_ptr(mclass), thiz);
  if (check_exc(mrb)) {
    return;
  }

  mrb_iv_set(mrb, mmain_class, mrb_intern_cstr(mrb, "@main"), mobj);
}

