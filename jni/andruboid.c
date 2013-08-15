#include <jni.h>
#include <stdio.h>
#include <errno.h>

#include "mruby-all.h"

char err[1024] = {0};
int debug = 0;

static void jobj_free(mrb_state *mrb, void *p) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  if (p) {
    (*env)->DeleteGlobalRef(env, (jobject)p);
  }
}

static const struct mrb_data_type jobj_data_type = {
  "jobject", jobj_free, 
};

static mrb_value jdefinition__set_class_path(mrb_state *mrb, mrb_value self) {
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
  jobject jglobal;

  jglobal = (*env)->NewGlobalRef(env, jobj);
  mobj = mrb_obj_value(Data_Wrap_Struct(mrb, klass, &jobj_data_type, (void*)jglobal));
  (*env)->DeleteLocalRef(env, jobj);
  return mobj;
}

struct RJMethod;

typedef mrb_value (*caller_t)(mrb_state*, mrb_value, struct RJMethod*);

struct RJMethod {
  jmethodID id;
  caller_t caller;
  union opt1 {
    struct RClass *klass;
    struct RObject *obj;
  } opt1;
  union opt2 {
    int depth;
  } opt2;
  int argc;
  jvalue *argv;
  char *types;
};

static void jmeth_free(mrb_state *mrb, void *p) {
  struct RJMethod *smeth = (struct RJMethod *)p;
  if (smeth->argv) {
    free(smeth->argv);
  }
  if (smeth->types) {
    free(smeth->types);
  }
  free(p);
}

static const struct mrb_data_type jmeth_data_type = {
  "jmethod", jmeth_free, 
};

static jarray jmeth_i__start_enum_ary(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth, mrb_value *pmary, int *psize) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jarray jary;

  jary = (jarray)(*env)->CallObjectMethodA(env, (jobject)DATA_PTR(mobj), rmeth->id, rmeth->argv);
  if (!jary) {
    return 0;
  }
  if (rmeth->opt2.depth != 1) {
    mrb_raisef(mrb, E_RUNTIME_ERROR, "TODO: return nested array");
  }

  *psize = (*env)->GetArrayLength(env, jary);
  *pmary = mrb_ary_new_capa(mrb, *psize);
  return jary;
}

static mrb_value jmeth_i__call_void(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;

  (*env)->CallVoidMethodA(env, (jobject)DATA_PTR(mobj), rmeth->id, rmeth->argv);
  return mobj;
}

static mrb_value jmeth_i__call_void_static(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jclass jclazz;

  jclazz = (jclass)DATA_PTR(mrb_iv_get(mrb, mobj, mrb_intern_cstr(mrb, "jclass")));
  (*env)->CallStaticVoidMethodA(env, jclazz, rmeth->id, rmeth->argv);
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

static mrb_value jmeth_i__call_int_static(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jint ji;
  jclass jclazz;

  jclazz = (jclass)DATA_PTR(mrb_iv_get(mrb, mobj, mrb_intern_cstr(mrb, "jclass")));
  ji = (*env)->CallStaticIntMethodA(env, jclazz, rmeth->id, rmeth->argv);
  return mrb_fixnum_value(ji);
}

static mrb_value jmeth_i__call_long(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jlong jl;

  jl = (*env)->CallLongMethodA(env, (jobject)DATA_PTR(mobj), rmeth->id, rmeth->argv);
  return mrb_float_value(mrb, (float)jl);
}

static mrb_value jmeth_i__call_float(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jfloat jf;

  jf = (*env)->CallFloatMethodA(env, (jobject)DATA_PTR(mobj), rmeth->id, rmeth->argv);
  return mrb_float_value(mrb, jf);
}

static mrb_value jstr2mstr(mrb_state *mrb, jstring jstr) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  mrb_value mstr;
  jsize size;
  const char *cstr;

  size = (*env)->GetStringUTFLength(env, jstr);
  cstr = (*env)->GetStringUTFChars(env, jstr, NULL);
  mstr = mrb_str_new(mrb, cstr, size);

  (*env)->ReleaseStringUTFChars(env, jstr, cstr);
  (*env)->DeleteLocalRef(env, jstr);
  return mstr;
}

static mrb_value jmeth_i__call_str(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jstring jstr;

  jstr = (*env)->CallObjectMethodA(env, (jobject)DATA_PTR(mobj), rmeth->id, rmeth->argv);
  if (!jstr) {
    return mrb_nil_value();
  }
  return jstr2mstr(mrb, jstr);
}

static mrb_value jmeth_i__wrap_jclassobj(mrb_state *mrb, mrb_value mobj, jobject jobj) {
  mrb_value mclassclass;
  mclassclass = mrb_str_new(mrb, "java.lang.Class", 15);
  mclassclass = mrb_funcall(mrb, mobj, "name2class", 1, mclassclass);
  return wrap_jobject(mrb, mrb_class_ptr(mclassclass), jobj);
}

static mrb_value jmeth_i__jclass2mclass(mrb_state *mrb, jobject jobj, mrb_value mobj) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jstring jname;
  mrb_value mclass, mname, mclassobj;
  const char *cname;
  jsize size;
  jclass jclazz;
  jmethodID jmeth;

  if (!jobj) {
    return mrb_nil_value();
  }
  jclazz = (*env)->GetObjectClass(env, jobj);
  jmeth = (*env)->GetMethodID(env, jclazz, "getName", "()Ljava/lang/String;");
  (*env)->DeleteLocalRef(env, jclazz);

  jname = (*env)->CallObjectMethod(env, jobj, jmeth);
  size = (*env)->GetStringUTFLength(env, jname);
  cname = (*env)->GetStringUTFChars(env, jname, NULL);
  mname = mrb_str_new(mrb, cname, size);
  (*env)->ReleaseStringUTFChars(env, jname, cname);
  (*env)->DeleteLocalRef(env, jname);

  mclass = mrb_funcall(mrb, mobj, "name2class", 1, mname);
  if (mrb_nil_p(mclass)) {
    return jmeth_i__wrap_jclassobj(mrb, mobj, jobj);
  }
  mclassobj = mrb_iv_get(mrb, mclass, mrb_intern_cstr(mrb, "@jclassobj"));
  if (mrb_nil_p(mclassobj)) {
    mclassobj = jmeth_i__wrap_jclassobj(mrb, mobj, jobj);
    mrb_iv_set(mrb, mclass, mrb_intern_cstr(mrb, "@jclassobj"), mclassobj);
  } else {
    (*env)->DeleteLocalRef(env, jobj);
  }
  return mclass;
}

static mrb_value jmeth_i__call_class(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jobject jobj;

  jobj = (*env)->CallObjectMethodA(env, (jobject)DATA_PTR(mobj), rmeth->id, rmeth->argv);
  return jmeth_i__jclass2mclass(mrb, jobj, mobj);
}

static mrb_value jmeth_i__call_class_ary(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jobject jobj;
  jarray jary;
  mrb_value mitem, mary;
  int i, ai, size;

  jary = jmeth_i__start_enum_ary(mrb, mobj, rmeth, &mary, &size);
  if (!jary) {
    return mrb_nil_value();
  }

  for (i = 0; i < size; i++) {
    ai = mrb_gc_arena_save(mrb);
    jobj = (*env)->GetObjectArrayElement(env, jary, i);
    mitem = jmeth_i__jclass2mclass(mrb, jobj, mobj);
    mrb_ary_push(mrb, mary, mitem);
    mrb_gc_arena_restore(mrb, ai);
  }
  (*env)->DeleteLocalRef(env, jary);
  return mary;
}

static mrb_value jmeth_i__call_class_static(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jobject jobj;
  jclass jclazz;

  jclazz = (jclass)DATA_PTR(mrb_iv_get(mrb, mobj, mrb_intern_cstr(mrb, "jclass")));
  jobj = (*env)->CallStaticObjectMethodA(env, jclazz, rmeth->id, rmeth->argv);
  if (!jobj) {
    return mrb_nil_value();
  }
  return jmeth_i__jclass2mclass(mrb, jobj, mobj);
}

static mrb_value jmeth_i__call_obj(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jobject jobj;

  jobj = (*env)->CallObjectMethodA(env, (jobject)DATA_PTR(mobj), rmeth->id, rmeth->argv);
  if (!jobj) {
    return mrb_nil_value();
  }
  return wrap_jobject(mrb, rmeth->opt1.klass, jobj);
}

static mrb_value jmeth_i__call_obj_static(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jobject jobj;

  mobj = mrb_iv_get(mrb, mobj, mrb_intern_cstr(mrb, "jclass"));
  jobj = (*env)->CallStaticObjectMethodA(env, (jclass)DATA_PTR(mobj), rmeth->id, rmeth->argv);
  if (!jobj) {
    return mrb_nil_value();
  }
  return wrap_jobject(mrb, rmeth->opt1.klass, jobj);
}

static mrb_value jmeth_i__call_obj_ary(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jobjectArray jary;
  jobject jobj;
  mrb_value mitem, mary;
  int size, i;
  int ai;

  jary = jmeth_i__start_enum_ary(mrb, mobj, rmeth, &mary, &size);
  if (!jary) {
    return mrb_nil_value();
  }

  for (i = 0; i < size; i++) {
    ai = mrb_gc_arena_save(mrb);
    jobj = (*env)->GetObjectArrayElement(env, jary, i);
    mitem = wrap_jobject(mrb, rmeth->opt1.klass, jobj);
    mrb_ary_push(mrb, mary, mitem);
    mrb_gc_arena_restore(mrb, ai);
  }
  (*env)->DeleteLocalRef(env, jary);
  return mary;
}

static mrb_value jmeth_i__call_constructor(mrb_state *mrb, mrb_value mobj, struct RJMethod *rmeth) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  jclass jclazz;
  jobject jobj;

  DATA_TYPE(mobj) = &jobj_data_type;
  DATA_PTR(mobj) = NULL;

  jclazz = DATA_PTR(mrb_obj_value(rmeth->opt1.obj));
  jobj = (*env)->NewObjectA(env, jclazz, rmeth->id, rmeth->argv);
  if (jobj) {
    DATA_PTR(mobj) = (*env)->NewGlobalRef(env, jobj);
    (*env)->DeleteLocalRef(env, jobj);
  } else {
    mrb_raisef(mrb, E_RUNTIME_ERROR, "constructor returns null");
  }
  return mobj;
}

#define FLAG_STATIC (1 << 8)
#define FLAG_ARY (1 << 9)
#define CALLER_TYPE(c, s, d) ((c) | ((s) ? FLAG_STATIC : 0) | ((d) ? FLAG_ARY : 0))

static inline caller_t type2caller(const char *ctype, int is_static, int depth) {
  switch (CALLER_TYPE(ctype[0], is_static, depth)) {
    case 'V': {
      return jmeth_i__call_void;
    } break;
    case 'V' | FLAG_STATIC: {
      return jmeth_i__call_void_static;
    } break;
    case 'Z': {
      return jmeth_i__call_bool;
    } break;
    case 'I': {
      return jmeth_i__call_int;
    } break;
    case 'I' | FLAG_STATIC: {
      return jmeth_i__call_int_static;
    } break;
    case 'J': {
      return jmeth_i__call_long;
    } break;
    case 'F': {
      return jmeth_i__call_float;
    } break;
    case 's': {
      return jmeth_i__call_str;
    } break;
    case 'c': {
      return jmeth_i__call_class;
    } break;
    case 'c' | FLAG_ARY: {
      return jmeth_i__call_class_ary;
    } break;
    case 'c' | FLAG_STATIC: {
      return jmeth_i__call_class_static;
    } break;
    case 'L': {
      return jmeth_i__call_obj;
    } break;
    case 'L' | FLAG_STATIC: {
      return jmeth_i__call_obj_static;
    } break;
    case 'L' | FLAG_ARY: {
      return jmeth_i__call_obj_ary;
    } break;
  }
  return NULL;
}

static mrb_value jmeth__initialize(mrb_state *mrb, mrb_value self) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  mrb_value miclass, mclass, mname, mret, margs, msig;
  jclass jclazz;
  jmethodID jmeth;
  char *cname, *csig;
  struct RJMethod *smeth = (struct RJMethod *)malloc(sizeof(struct RJMethod));
  int is_static = 0;
  struct RArray *ary;

  DATA_TYPE(self) = &jmeth_data_type;
  DATA_PTR(self) = smeth;
  smeth->types = NULL;

  mrb_get_args(mrb, "oooo", &miclass, &mret, &mname, &margs);
  if (mrb_type(miclass) == MRB_TT_SCLASS) {
    is_static = 1;
    miclass = mrb_iv_get(mrb, miclass, mrb_intern_cstr(mrb, "__attached__"));
  }
  mclass = mrb_iv_get(mrb, miclass, mrb_intern_cstr(mrb, "jclass"));
  jclazz = DATA_PTR(mclass);
  cname = mrb_string_value_cstr(mrb, &mname);

  msig = mrb_funcall(mrb, miclass, "get_type", 1, margs);
  csig = mrb_string_value_cstr(mrb, &msig);
  smeth->types = (char*)malloc(RSTRING_LEN(msig) + 1);
  memcpy(smeth->types, csig, RSTRING_LEN(msig) + 1);

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
    smeth->opt1.obj = mrb_obj_ptr(mclass);
    smeth->caller = jmeth_i__call_constructor;
  } else {
    struct RClass *rmod = mrb_class_get(mrb, "Jmi");
    int depth = 0;

    rmod = mrb_class_ptr(mrb_const_get(mrb, mrb_obj_value(rmod), mrb_intern_cstr(mrb, "Generics")));
    while (mrb_type(mret) == MRB_TT_ARRAY && RARRAY_LEN(mret)) {
      depth++;
      mret = *RARRAY_PTR(mret);
    }
    smeth->opt1.klass = mrb_class_ptr(mret);
    if (rmod == smeth->opt1.klass) { /* Generics */
      miclass = mrb_iv_get(mrb, miclass, mrb_intern_cstr(mrb, "@iclass"));
      smeth->opt1.klass = mrb_class_ptr(miclass);
    }

    msig = mrb_funcall(mrb, miclass, "class2type", 1, mret);
    csig = mrb_string_value_cstr(mrb, &msig);
    smeth->caller = type2caller(csig, is_static, depth);
    smeth->opt2.depth = depth;
    if (!smeth->caller) {
      mrb_value mstatic = mrb_str_new_cstr(mrb, is_static ? "static " : "");
      mrb_value misary = mrb_str_new_cstr(mrb, depth ? "array " : "");
      mrb_raisef(mrb, E_RUNTIME_ERROR, "Jmi: return type error: %S%S%S", mstatic, misary, msig);
    }
  }
  smeth->argc = ary->len;
  smeth->argv = (jvalue *)malloc(ary->len * sizeof(jvalue));
  DATA_TYPE(self) = &jmeth_data_type;
  DATA_PTR(self) = smeth;

  return self;
}

#define TYPE_VAL(c, mtype) (((int)(unsigned char)c) | ((mtype) << 8))

static mrb_value jmeth__setup(mrb_state *mrb, mrb_value self) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  mrb_value margs;
  struct RJMethod *smeth = DATA_PTR(self);
  struct RArray *ary;
  int i;
  char *types = smeth->types;

  mrb_get_args(mrb, "o", &margs);
  ary = mrb_ary_ptr(margs);
  if (ary->len != smeth->argc) {
    return mrb_false_value();
  }
  for (i = 0; i < ary->len; i++) {
    smeth->argv[i].i = 0;
  }
  for (i = 0; i < ary->len; i++) {
    mrb_value item = ary->ptr[i];
    jvalue *jarg = smeth->argv + i;

    switch (TYPE_VAL(*types, mrb_type(item))) {
      case TYPE_VAL('Z', MRB_TT_FALSE):
      case TYPE_VAL('Z', MRB_TT_TRUE): {
        jarg->z = mrb_bool(item);
      } break;
      case TYPE_VAL('I', MRB_TT_FIXNUM): {
        jarg->i = mrb_fixnum(item);
      } break;
      case TYPE_VAL('F', MRB_TT_FLOAT): {
        jarg->f = mrb_float(item);
      } break;
      case TYPE_VAL('F', MRB_TT_FIXNUM): {
        jarg->f = mrb_fixnum(item);
      } break;
      case TYPE_VAL('s', MRB_TT_STRING): {
        jarg->l = (jobject)(*env)->NewStringUTF(env, mrb_string_value_cstr(mrb, &item));
      } break;
      case TYPE_VAL('L', MRB_TT_FALSE): {
        types = strchr(types, ';');
        jarg->l = (jobject)NULL;
      } break;
      case TYPE_VAL('L', MRB_TT_DATA): {
        char *cname = types + 1;
        mrb_value mclass;

        types = strchr(types, ';');
        mclass = mrb_str_new(mrb, cname, types - cname);
        mclass = mrb_funcall(mrb, item, "name2class", 1, mclass);
        if (mrb_nil_p(mclass)) {
          return mrb_false_value();
        }
        if (!mrb_obj_is_kind_of(mrb, item, mrb_class_ptr(mclass))) {
          return mrb_false_value();
        }
        jarg->l = (jobject)DATA_PTR(item);
      } break;
      default: {
        return mrb_false_value();
      }
    }
    types++;
  }
  return mrb_true_value();
}

static mrb_value jmeth__call(mrb_state *mrb, mrb_value self) {
  JNIEnv* env = (JNIEnv*)mrb->ud;
  mrb_value mobj;
  struct RJMethod *smeth;
  int i;
  char *types;

  smeth = DATA_PTR(self);
  mrb_get_args(mrb, "o", &mobj);

  mobj = smeth->caller(mrb, mobj, smeth);
  types = smeth->types;
  for (i = 0; i < smeth->argc; i++) {
    jvalue *jarg = smeth->argv + i;
    switch (*(++types)) {
      case 's': {
        (*env)->DeleteLocalRef(env, jarg->l);
      } break;
      case 'L': {
        while (*types && *types != ';') {
          types++;
        }
      } break;
    }
  }
  if ((*env)->ExceptionCheck(env)) {
    mrb_raisef(mrb, E_RUNTIME_ERROR, "exception in java method");
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
  jclazz = DATA_PTR(mrb_iv_get(mrb, mclass, mrb_intern_cstr(mrb, "jclass")));

  cname = mrb_string_value_cstr(mrb, &mname);
  mstr = mrb_funcall(mrb, mmod, "class2sig", 1, mret);
  cstr = mrb_string_value_cstr(mrb, &mstr);
  fid = (*env)->GetStaticFieldID(env, jclazz, cname, cstr);
  if ((*env)->ExceptionCheck(env)) {
    mrb_raisef(mrb, E_NAME_ERROR, "Jmi: can't get field %S", mstr);
  }

  mstr = mrb_funcall(mrb, mmod, "class2type", 1, mret);
  cstr = mrb_string_value_cstr(mrb, &mstr);
  switch (cstr[0]) {
    case 'Z': {
      jboolean jval;
      jval = (*env)->GetStaticBooleanField(env, jclazz, fid);
      return jval ? mrb_true_value() : mrb_false_value();
    } break;
    case 'I': {
      jint jval;
      jval = (*env)->GetStaticIntField(env, jclazz, fid);
      return mrb_fixnum_value(jval);
    } break;
    case 'L': {
      jobject jval;
      jval = (*env)->GetStaticObjectField(env, jclazz, fid);
      return wrap_jobject(mrb, mrb_class_ptr(mret), jval);
    } break;
    case 's': {
      jstring jstr;
      jstr = (*env)->GetStaticObjectField(env, jclazz, fid);
      return jstr2mstr(mrb, jstr);
    } break;
  }
  mclass = mrb_funcall(mrb, mclass, "inspect", 0);
  mrb_raisef(mrb, E_RUNTIME_ERROR, "unsupported field: %S == %S in %S", mstr, mname, mclass);
  return mrb_nil_value();
}

static mrb_value jmi_s__debug(mrb_state *mrb, mrb_value self) {
  debug = !debug;
  return mrb_nil_value();
}

static struct RClass *init_jmi(mrb_state *mrb) {
  struct RClass *klass, *mod;
  mod = mrb_define_module(mrb, 
    "Jmi");
  mrb_define_singleton_method(mrb, (struct RObject *)mod, "set_classpath", jmi_s__set_class_path, ARGS_REQ(2));
  mrb_define_singleton_method(mrb, (struct RObject *)mod, "get_field_static", jmi_s__get_field_static, ARGS_REQ(3));
  mrb_define_singleton_method(mrb, (struct RObject *)mod, "debug", jmi_s__debug, ARGS_NONE());

  klass = mrb_define_module_under(mrb, mod,
    "Definition");
  mrb_define_method(mrb, klass, "class_path=", jdefinition__set_class_path, ARGS_REQ(1));

  klass = mrb_define_class_under(mrb, mod,
    "Method", mrb->object_class);
  MRB_SET_INSTANCE_TT(klass, MRB_TT_DATA);
  mrb_define_method(mrb, klass, "initialize", jmeth__initialize, ARGS_REQ(3));
  mrb_define_method(mrb, klass, "setup", jmeth__setup, ARGS_REQ(1));
  mrb_define_method(mrb, klass, "call", jmeth__call, ARGS_REQ(1));

  klass = mrb_define_class_under(mrb, mod,
    "Object", mrb->object_class);
  MRB_SET_INSTANCE_TT(klass, MRB_TT_DATA);

  return mod;
}

static int check_exc(mrb_state *mrb) {
  JNIEnv* env = (JNIEnv*)mrb->ud;

  if (mrb->exc) {
    mrb_value mstr;
    jclass jclazz;
    if ((*env)->ExceptionCheck(env)) {
      mrb->exc = 0;
      return 1;
    }
    mstr = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
    mrb->exc = 0;
    jclazz = (*env)->FindClass(env, "java/lang/RuntimeException");
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

  debug = 0;
  mrb->ud = (void*)env;
  init_jmi(mrb);
  mrb_gc_arena_restore(mrb, ai);

  return (jint)mrb;
}

void Java_com_github_wanabe_Andruboid_evalScript(JNIEnv* env, jobject thiz, jint jmrb, jstring jname, jstring jscr) {
  mrb_state *mrb = (mrb_state *)jmrb;
  const char *cname, *cscr;
  int ai = mrb_gc_arena_save(mrb);
  mrbc_context *cxt = mrbc_context_new(mrb);

  cscr = (*env)->GetStringUTFChars(env, jscr, NULL);
  cname = (*env)->GetStringUTFChars(env, jname, NULL);
  mrbc_filename(mrb, cxt, cname);
  mrb_load_string_cxt(mrb, cscr, cxt);
  mrbc_context_free(mrb, cxt);
  mrb_gc_arena_restore(mrb, ai);
  (*env)->ReleaseStringUTFChars(env, jname, cname);
  (*env)->ReleaseStringUTFChars(env, jscr, cscr);
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
  mobj = wrap_jobject(mrb, mrb_class_ptr(mclass), 
    (*env)->NewLocalRef(env, thiz));
  mrb_funcall(mrb, mobj, "initialize", 0);

  mrb_gc_arena_restore(mrb, ai);
  check_exc(mrb);
}

void Java_com_github_wanabe_Andruboid_handle(JNIEnv* env, jobject thiz, jint jmrb, jint jtype, jint jid, jint jopt) {
  mrb_state *mrb = (mrb_state *)jmrb;
  int ai = mrb_gc_arena_save(mrb);
  struct RClass *mod = mrb_class_get(mrb, "Jmi");
  mrb_value mclass = mrb_const_get(mrb, mrb_obj_value(mod), mrb_intern_cstr(mrb, "Listener"));

  mrb_funcall(mrb, mclass, "call", 3, mrb_fixnum_value(jtype), mrb_fixnum_value(jid), mrb_fixnum_value(jopt));
  mrb_gc_arena_restore(mrb, ai);
  check_exc(mrb);
}

void Java_com_github_wanabe_Andruboid_close(JNIEnv* env, jobject thiz, jint jmrb) {
  mrb_state *mrb = (mrb_state *)jmrb;
  mrb_close(mrb);
}

