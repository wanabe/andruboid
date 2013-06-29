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
  jclass jclass, jglobal;
  JNIEnv* env = (JNIEnv*)mrb->ud;

  mrb_get_args(mrb, "o", &mpath);
  cpath = mrb_string_value_cstr(mrb, &mpath);
  jclass = (*env)->FindClass(env, cpath);
  jglobal = (*env)->NewGlobalRef(env, jclass);
  mobj = mrb_obj_value(Data_Wrap_Struct(mrb, mrb->object_class, &jobj_data_type, (void*)jglobal));
  mrb_iv_set(mrb, self, mrb_intern_cstr(mrb, "jclass"), mobj);

  (*env)->DeleteLocalRef(env, jclass);
  return mpath;
}

static mrb_value jobj__initialize(mrb_state *mrb, mrb_value self) {
  char *cpath, *csig;
  jclass jclass;
  jmethodID jmeth;
  jobject jobj, jarg;
  JNIEnv* env = (JNIEnv*)mrb->ud;
  mrb_value mobj, mstr, mclass = mrb_obj_value(mrb_obj_class(mrb, self));

  mrb_get_args(mrb, "o", &mobj); // TODO
  jarg = DATA_PTR(mobj);

  mobj = mrb_iv_get(mrb, mclass, mrb_intern_cstr(mrb, "jclass"));
  jclass = DATA_PTR(mobj);

  mstr = mrb_iv_get(mrb, mclass, mrb_intern_cstr(mrb, "@init_sig"));
  csig = mrb_string_value_cstr(mrb, &mstr);
  jmeth = (*env)->GetMethodID(env, jclass, "<init>", csig);

  jobj = (*env)->NewObject(env, jclass, jmeth, jarg);
  DATA_PTR(self) = (*env)->NewGlobalRef(env, jobj);
  
  (*env)->DeleteLocalRef(env, jobj);
  return self;
}

static mrb_value wrap_jobject(mrb_state *mrb, struct RClass *klass, jobject jobj) {
  mrb_value mobj;
  JNIEnv* env = (JNIEnv*)mrb->ud;

  jobj = (*env)->NewGlobalRef(env, jobj);
  mobj = mrb_obj_value(Data_Wrap_Struct(mrb, klass, &jobj_data_type, (void*)jobj));
  mrb_funcall(mrb, mobj, "initialize", 0);
  return mobj;
}

static mrb_value jmain__initialize(mrb_state *mrb, mrb_value self) {
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
  mrb_value mclass, mname, msig, mstr;
  jclass jclass;
  jmethodID jmeth;
  char *cname, *csig;
  struct RJMethod *smeth = (struct RJMethod *)malloc(sizeof(struct RJMethod));

  mrb_get_args(mrb, "ooo", &mclass, &mname, &msig);
  mclass = mrb_iv_get(mrb, mclass, mrb_intern_cstr(mrb, "jclass"));
  jclass = DATA_PTR(mclass);
  cname = mrb_sym2name(mrb, mrb_symbol(mname));
  if (cname[0] == '"') {
    mname = mrb_funcall(mrb, mname, "to_s", 0);
    cname = mrb_string_value_cstr(mrb, &mname);
  }
  csig = mrb_string_value_cstr(mrb, &msig);
  jmeth = (*env)->GetMethodID(env, jclass, cname, csig);

  smeth->id = jmeth;
  smeth->type = cname[0] == '<' ? 2 : csig[2] != 'a' ? 1 : 0; // TODO
  DATA_TYPE(self) = &jmeth_data_type;
  DATA_PTR(self) = smeth;
  
  return self;
}

static mrb_value jmeth__call(mrb_state *mrb, mrb_value self) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  mrb_value mobj, marg;
  struct RJMethod *smeth;
  jobject jobj;

  mrb_get_args(mrb, "oo", &mobj, &marg); // TODO

  smeth = DATA_PTR(self);

  switch (smeth->type) { //TODO
    case 2: {
      jclass jclass;
      mrb_value mclass = mrb_obj_value(mrb_obj_class(mrb, mobj));
      mclass = mrb_iv_get(mrb, mclass, mrb_intern_cstr(mrb, "jclass"));
      jclass = DATA_PTR(mclass);
      jobj = (jobject)DATA_PTR(marg);
      jobj = (*env)->NewObject(env, jclass, smeth->id, jobj);
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
  mrb_define_singleton_method(mrb, klass, "class_path=", jobj_s__set_class_path, ARGS_REQ(1));

  return mod;
}

static void load_init_script(mrb_state *mrb, JNIEnv* env, jobject jact, jobjectArray scrs) {
  FILE *fp;
  mrb_value mobj, mstr, mclass, mmain_class;
  jstring scr;
  jshort len;
  int i;
  struct RClass *mod, *klass;

  mrb->ud = (void*)env;
  mod = init_jmi(mrb);

  len = (*env)->GetArrayLength(env, scrs);
  for(i = 0; i < len; i++) {
    scr = (*env)->GetObjectArrayElement(env, scrs, i);
    mstr = mrb_load_string(mrb, (*env)->GetStringUTFChars(env, scr, NULL));
    if (mrb->exc) {
      mstr = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
      strcat(err, mrb_string_value_cstr(mrb, &mstr));
      return;
    }
  }

  mmain_class = mrb_const_get(mrb, mrb_obj_value(mod), mrb_intern_cstr(mrb, "Main"));
  klass = mrb_class_ptr(mmain_class);
  MRB_SET_INSTANCE_TT(klass, MRB_TT_DATA);

  if (mrb->exc) {
    mstr = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
    strcat(err, mrb_string_value_cstr(mrb, &mstr));
    return;
  }

  mclass = mrb_iv_get(mrb, mmain_class, mrb_intern_cstr(mrb, "@main"));
  mobj = wrap_jobject(mrb, mrb_class_ptr(mclass), jact);

  if (mrb->exc) {
    mstr = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
    strcat(err, mrb_string_value_cstr(mrb, &mstr));
    return;
  }
  mrb_iv_set(mrb, mmain_class, mrb_intern_cstr(mrb, "@main"), mobj);
}

jstring Java_com_github_wanabe_Andruboid_initialize(JNIEnv* env, jobject thiz, jobjectArray scrs) {
  mrb_state *mrb = mrb_open();

  load_init_script(mrb, env, thiz, scrs);
  return (*env)->NewStringUTF(env, err);
}

