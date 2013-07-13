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

static mrb_value jclass__set_class_path(mrb_state *mrb, mrb_value self) {
  mrb_value mobj, mpath;
  char *cpath;
  jclass jclazz, jglobal;
  JNIEnv* env = (JNIEnv*)mrb->ud;

  mrb_get_args(mrb, "o", &mpath);
  cpath = mrb_string_value_cstr(mrb, &mpath);
  jclazz = (*env)->FindClass(env, cpath);
  if ((*env)->ExceptionCheck(env)) {
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
  return mobj;
}

struct RJMethod;

typedef mrb_value (*caller_t)(mrb_state*, mrb_value, struct RJMethod*);

struct RJMethod {
  jmethodID id;
  caller_t caller;
  union {
    struct RClass *klass;
    struct RObject *obj;
  };
  int argc;
  jvalue *argv;
};

static void jmeth_free(mrb_state *mrb, void *p) {
  free(p);
}

static const struct mrb_data_type jmeth_data_type = {
  "jmethod", jmeth_free, 
};

static mrb_value jmeth_i__call_void(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;

  (*env)->CallVoidMethodA(env, (jobject)DATA_PTR(mobj), rmeth->id, rmeth->argv);
  return mobj;
}

static mrb_value jmeth_i__call_bool(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jboolean jb;

  jb = (*env)->CallBooleanMethodA(env, (jobject)DATA_PTR(mobj), rmeth->id, rmeth->argv);
  return mrb_bool_value(jb);
}

static mrb_value jmeth_i__call_int(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jint ji;

  ji = (*env)->CallIntMethodA(env, (jobject)DATA_PTR(mobj), rmeth->id, rmeth->argv);
  return mrb_fixnum_value(ji);
}

static mrb_value jmeth_i__call_str(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jstring jstr;
  mrb_value mstr = mrb_nil_value();
  jsize size;
  const char *cstr;

  jstr = (*env)->CallObjectMethodA(env, (jobject)DATA_PTR(mobj), rmeth->id, rmeth->argv);
  if (!jstr) {
    return mrb_nil_value();
  }
  size = (*env)->GetStringUTFLength(env, jstr);
  cstr = (*env)->GetStringUTFChars(env, jstr, NULL);
  mstr = mrb_str_new(mrb, cstr, size);

  (*env)->ReleaseStringUTFChars(env, jstr, cstr);
  (*env)->DeleteLocalRef(env, jstr);
  return mstr;
}

static mrb_value jmeth_i__call_obj(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jobject jobj;

  jobj = (*env)->CallObjectMethodA(env, (jobject)DATA_PTR(mobj), rmeth->id, rmeth->argv);
  if (!jobj) {
    return mrb_nil_value();
  }
  return wrap_jobject(mrb, rmeth->klass, jobj);
}

static mrb_value jmeth_i__call_obj_static(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jobject jobj;

  mobj = mrb_iv_get(mrb, mobj, mrb_intern_cstr(mrb, "jclass"));
  jobj = (*env)->CallStaticObjectMethodA(env, (jclass)DATA_PTR(mobj), rmeth->id, rmeth->argv);
  if (!jobj) {
    return mrb_nil_value();
  }
  return wrap_jobject(mrb, rmeth->klass, jobj);
}

static mrb_value jmeth_i__call_constructor(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jclass jclazz;
  jobject jobj;

  jclazz = DATA_PTR(mrb_obj_value(rmeth->obj));
  jobj = (*env)->NewObjectA(env, jclazz, rmeth->id, rmeth->argv);
  DATA_PTR(mobj) = (*env)->NewGlobalRef(env, jobj);
  (*env)->DeleteLocalRef(env, jobj);
  return mobj;
}

struct {
  char type;
  caller_t caller;
  caller_t caller_static;
} caller_table[] = {
  {'V', jmeth_i__call_void},
  {'Z', jmeth_i__call_bool},
  {'I', jmeth_i__call_int},
  {'s', jmeth_i__call_str},
  {'L', jmeth_i__call_obj, jmeth_i__call_obj_static},
  {0, 0}
};

static mrb_value jmeth__initialize(mrb_state *mrb, mrb_value self) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  mrb_value miclass, mclass, mname, mret, margs, msig;
  jclass jclazz;
  jmethodID jmeth;
  char *cname, *csig;
  struct RJMethod *smeth = (struct RJMethod *)malloc(sizeof(struct RJMethod));
  int i, is_static = 0;
  struct RArray *ary;

  mrb_get_args(mrb, "oooo", &miclass, &mret, &mname, &margs);
  if (mrb_type(miclass) == MRB_TT_SCLASS) {
    is_static = 1;
    miclass = mrb_iv_get(mrb, miclass, mrb_intern_cstr(mrb, "__attached__"));
  }
  mclass = mrb_iv_get(mrb, miclass, mrb_intern_cstr(mrb, "jclass"));
  jclazz = DATA_PTR(mclass);
  cname = mrb_string_value_cstr(mrb, &mname);

  msig = mrb_funcall(mrb, self, "get_sig", 2, mret, margs);
  csig = mrb_string_value_cstr(mrb, &msig);
  if (is_static) {
    jmeth = (*env)->GetStaticMethodID(env, jclazz, cname, csig);
  } else {
    jmeth = (*env)->GetMethodID(env, jclazz, cname, csig);
  }
  if ((*env)->ExceptionCheck(env)) {
    mrb_raisef(mrb, E_NAME_ERROR, "Jmi: can't get %S%S", mname, msig);
  }

  ary = mrb_ary_ptr(margs);
  smeth->id = jmeth;
  if (cname[0] == '<') { /* <init> */
    smeth->obj = mrb_obj_ptr(mclass);
    smeth->caller = jmeth_i__call_constructor;
  } else {
    char c;
    struct RClass *rmod = mrb_class_get(mrb, "Jmi");
    
    rmod = mrb_class_ptr(mrb_const_get(mrb, mrb_obj_value(rmod), mrb_intern_cstr(mrb, "Generics")));
    smeth->klass = mrb_class_ptr(mret);
    if (rmod == smeth->klass) { /* Generics */
      miclass = mrb_iv_get(mrb, miclass, mrb_intern_cstr(mrb, "@iclass"));
      smeth->klass = mrb_class_ptr(miclass);
    }

    msig = mrb_funcall(mrb, self, "class2type", 1, mret);
    c = mrb_string_value_cstr(mrb, &msig)[0];
    for(i = 0; ; i++) {
      char type = caller_table[i].type;
      if (!type) {
        mrb_raisef(mrb, E_RUNTIME_ERROR, "Jmi: return type not found");
        break;
      }
      if (c == type) {
        smeth->caller = (&caller_table[i].caller)[is_static];
        break;
      }
    }
  }
  smeth->argc = ary->len;
  smeth->argv = (jvalue *)malloc(ary->len * sizeof(jvalue));
  DATA_TYPE(self) = &jmeth_data_type;
  DATA_PTR(self) = smeth;

  return self;
}

static mrb_value jmeth__call(mrb_state *mrb, mrb_value self) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  mrb_value mobj, mname, margs;
  struct RJMethod *smeth;
  struct RArray *ary;
  int i;

  smeth = DATA_PTR(self);
  mrb_get_args(mrb, "ooo", &mobj, &mname, &margs);
  ary = mrb_ary_ptr(margs);

  if (ary->len != smeth->argc) {
    mrb_raisef(mrb,E_ARGUMENT_ERROR, "Jmi: arg size wrong");
  }
  for (i = 0; i < ary->len; i++) {
    mrb_value item = ary->ptr[i];
    jvalue *jarg = smeth->argv + i;
    switch(mrb_type(item)) {
      case MRB_TT_FALSE:
      case MRB_TT_TRUE: {
        jarg->z = mrb_bool(item);
      } break;
      case MRB_TT_FIXNUM: {
        jarg->i = mrb_fixnum(item);
      } break;
      case MRB_TT_DATA: {
        jarg->l = (jobject)DATA_PTR(item);
      } break;
      case MRB_TT_STRING: {
        jarg->l = (jobject)(*env)->NewStringUTF(env, mrb_string_value_cstr(mrb, &item));
      } break;
    }
  }
  mobj = smeth->caller(mrb, mobj, smeth);
  for (i = 0; i < ary->len; i++) {
    jvalue *jarg = smeth->argv + i;
    switch(mrb_type(ary->ptr[i])) {
      case MRB_TT_STRING: {
        (*env)->DeleteLocalRef(env, jarg->l);
      } break;
    }
  }
  return mobj;
}

static mrb_value jmi_s__set_class_path(mrb_state *mrb, mrb_value self) {
  mrb_value mmod, mpath;
  mrb_get_args(mrb, "oo", &mmod, &mpath);
  mrb_iv_set(mrb, mmod, mrb_intern_cstr(mrb, "__classpath__"), mpath);
  return mrb_nil_value();
}

static mrb_value jmi_s__get_field_static(mrb_state *mrb, mrb_value self) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  mrb_value mmod, mstr, mclass, mret, mname;
  jfieldID fid;
  jclass jclazz;
  char *cname, *cstr;

  mmod = mrb_const_get(mrb, self, mrb_intern_cstr(mrb, "Object"));
  mrb_get_args(mrb, "ooo", &mclass, &mret, &mname);
  mclass = mrb_iv_get(mrb, mclass, mrb_intern_cstr(mrb, "jclass"));
  jclazz = DATA_PTR(mclass);

  cname = mrb_string_value_cstr(mrb, &mname);
  mstr = mrb_funcall(mrb, mmod, "class2sig", 1, mret);
  cstr = mrb_string_value_cstr(mrb, &mstr);
  fid = (*env)->GetStaticFieldID(env, jclazz, cname, cstr);
  mstr = mrb_funcall(mrb, mmod, "class2type", 1, mret);
  cstr = mrb_string_value_cstr(mrb, &mstr);
  switch (cstr[0]) {
    case 'I': {
      jint jval;
      jval = (*env)->GetStaticIntField(env, jclazz, fid);
      return mrb_fixnum_value(jval);
    } break;
  }
  mrb_raisef(mrb, E_RUNTIME_ERROR, "unsupported field: %S", mstr);
  return mrb_nil_value();
}

static struct RClass *init_jmi(mrb_state *mrb) {
  struct RClass *klass, *mod;
  mod = mrb_define_module(mrb, 
    "Jmi");
  mrb_define_singleton_method(mrb, (struct RObject *)mod, "set_classpath", jmi_s__set_class_path, ARGS_REQ(2));
  mrb_define_singleton_method(mrb, (struct RObject *)mod, "get_field_static", jmi_s__get_field_static, ARGS_REQ(3));

  klass = mrb_define_module_under(mrb, mod,
    "JClass");
  mrb_define_method(mrb, klass, "class_path=", jclass__set_class_path, ARGS_REQ(1));

  klass = mrb_define_class_under(mrb, mod,
    "Method", mrb->object_class);
  MRB_SET_INSTANCE_TT(klass, MRB_TT_DATA);
  mrb_define_method(mrb, klass, "initialize", jmeth__initialize, ARGS_REQ(3));
  mrb_define_method(mrb, klass, "call", jmeth__call, ARGS_REST());

  klass = mrb_define_class_under(mrb, mod,
    "Object", mrb->object_class);
  MRB_SET_INSTANCE_TT(klass, MRB_TT_DATA);

  return mod;
}

static int check_exc(mrb_state *mrb) {
  JNIEnv* env = (JNIEnv*)mrb->ud;

  if (mrb->exc) {
    if ((*env)->ExceptionCheck(env)) {
      return 1;
    }
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
  int ai = mrb_gc_arena_save(mrb);

  mrb->ud = (void*)env;
  init_jmi(mrb);
  mrb_gc_arena_restore(mrb, ai);

  return (jint)mrb;
}

void Java_com_github_wanabe_Andruboid_evalScript(JNIEnv* env, jobject thiz, jint jmrb, jstring scr) {
  mrb_state *mrb = (mrb_state *)jmrb;
  int ai = mrb_gc_arena_save(mrb);

  mrb_load_string(mrb, (*env)->GetStringUTFChars(env, scr, NULL));
  mrb_gc_arena_restore(mrb, ai);
  check_exc(mrb);
}

void Java_com_github_wanabe_Andruboid_run(JNIEnv* env, jobject thiz, jint jmrb) {
  mrb_state *mrb = (mrb_state *)jmrb;
  int ai = mrb_gc_arena_save(mrb);
  struct RClass *klass, *mod = mrb_class_get(mrb, "Jmi");
  mrb_value mmain_class, mclass, mobj;

  mmain_class = mrb_const_get(mrb, mrb_obj_value(mod), mrb_intern_cstr(mrb, "Main"));
  klass = mrb_class_ptr(mmain_class);
  MRB_SET_INSTANCE_TT(klass, MRB_TT_DATA);
  if (check_exc(mrb)) {
    mrb_gc_arena_restore(mrb, ai);
    return;
  }

  mclass = mrb_iv_get(mrb, mmain_class, mrb_intern_cstr(mrb, "@main"));
  mobj = wrap_jobject(mrb, mrb_class_ptr(mclass), thiz);
  mrb_funcall(mrb, mobj, "initialize", 0);

  mrb_gc_arena_restore(mrb, ai);
  check_exc(mrb);
}

void Java_com_github_wanabe_Andruboid_click(JNIEnv* env, jobject thiz, jint jmrb, jint jid) {
  mrb_state *mrb = (mrb_state *)jmrb;
  int ai = mrb_gc_arena_save(mrb);
  struct RClass *mod = mrb_class_get(mrb, "Jmi");
  mrb_value mclass = mrb_const_get(mrb, mrb_obj_value(mod), mrb_intern_cstr(mrb, "ClickListener"));

  mrb_funcall(mrb, mclass, "call", 1, mrb_fixnum_value(jid));
  mrb_gc_arena_restore(mrb, ai);
  check_exc(mrb);
}

