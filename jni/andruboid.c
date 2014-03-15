#include <jni.h>
#include <stdio.h>
#include <errno.h>

#include "mruby-all.h"

jint Java_com_github_wanabe_Andruboid_initialize(JNIEnv* env, jobject thiz, jstring jdir) {
  mrb_state *mrb = mrb_open();
  mrb_value mdir;
  int ai = mrb_gc_arena_save(mrb);
  jsize size;
  const char *cdir;

  mrb->ud = (void*)env;
  mrb_mruby_jni_init(mrb);
  cdir = (*env)->GetStringUTFChars(env, jdir, NULL);
  size = (*env)->GetStringUTFLength(env, jdir);
  mdir = mrb_str_new(mrb, cdir, size);
  mrb_ary_push(mrb, mrb_gv_get(mrb, mrb_intern_cstr(mrb, "$:")), mdir);
  (*env)->ReleaseStringUTFChars(env, jdir, cdir);
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
  mrb_mruby_jni_check_exc(mrb);
}

void Java_com_github_wanabe_Andruboid_run(JNIEnv* env, jobject thiz, jint jmrb) {
  mrb_state *mrb = (mrb_state *)jmrb;
  int ai = mrb_gc_arena_save(mrb);
  struct RClass *klass, *mod = mrb_module_get(mrb, "Jni");
  mrb_value mmain_class, mclass, mobj;

  mmain_class = mrb_const_get(mrb, mrb_obj_value(mod), mrb_intern_cstr(mrb, "Main"));
  klass = mrb_class_ptr(mmain_class);
  MRB_SET_INSTANCE_TT(klass, MRB_TT_DATA);
  if (mrb_mruby_jni_check_exc(mrb)) {
    mrb_gc_arena_restore(mrb, ai);
    return;
  }

  mclass = mrb_iv_get(mrb, mmain_class, mrb_intern_cstr(mrb, "@main"));
  mobj = mrb_mruby_jni_wrap_jobject(mrb, mrb_class_ptr(mclass), 
    (*env)->NewLocalRef(env, thiz));
  mrb_funcall(mrb, mobj, "initialize", 0);

  mrb_gc_arena_restore(mrb, ai);
  mrb_mruby_jni_check_exc(mrb);
}

void Java_com_github_wanabe_Andruboid_handle__IIII(JNIEnv* env, jobject thiz, jint jmrb, jint jtype, jint jid, jint jopt) {
  mrb_state *mrb = (mrb_state *)jmrb;
  int ai = mrb_gc_arena_save(mrb);
  struct RClass *mod = mrb_module_get(mrb, "Jni");
  mrb_value mclass = mrb_const_get(mrb, mrb_obj_value(mod), mrb_intern_cstr(mrb, "Listener"));

  mrb_funcall(mrb, mclass, "call", 3, mrb_fixnum_value(jtype), mrb_fixnum_value(jid), mrb_fixnum_value(jopt));
  mrb_gc_arena_restore(mrb, ai);
  mrb_mruby_jni_check_exc(mrb);
}

void Java_com_github_wanabe_Andruboid_handle__III_3I(JNIEnv* env, jobject thiz, jint jmrb, jint jtype, jint jid, jintArray jopt) {
  mrb_state *mrb = (mrb_state *)jmrb;
  int ai = mrb_gc_arena_save(mrb);
  struct RClass *mod = mrb_module_get(mrb, "Jni");
  mrb_value mary, mitem, mclass = mrb_const_get(mrb, mrb_obj_value(mod), mrb_intern_cstr(mrb, "Listener"));
  int i;
  jint *jints, size;

  size = (*env)->GetArrayLength(env, jopt);
  mary = mrb_ary_new_capa(mrb, size);
  jints = (*env)->GetIntArrayElements(env, jopt, NULL);
  for (i = 0; i < size; i++) {
    mitem = mrb_fixnum_value(jints[i]);
    mrb_ary_push(mrb, mary, mitem);
  }
  (*env)->ReleaseIntArrayElements(env, jopt, jints, 0);

  mrb_funcall(mrb, mclass, "call", 3, mrb_fixnum_value(jtype), mrb_fixnum_value(jid), mary);
  mrb_gc_arena_restore(mrb, ai);
  mrb_mruby_jni_check_exc(mrb);
}

void Java_com_github_wanabe_Andruboid_handle__IIILjava_lang_Object_2Ljava_lang_Class_2(JNIEnv* env, jobject thiz, jint jmrb, jint jtype, jint jid, jobject jopt, jobject jclassobj) {
  mrb_state *mrb = (mrb_state *)jmrb;
  int ai = mrb_gc_arena_save(mrb);
  struct RClass *mod = mrb_module_get(mrb, "Jni");
  mrb_value mobj, mclass = mrb_const_get(mrb, mrb_obj_value(mod), mrb_intern_cstr(mrb, "Listener"));

  mobj = mrb_const_get(mrb, mrb_obj_value(mod), mrb_intern_cstr(mrb, "Object"));
  mobj = mrb_mruby_jni_jclass2mclass(mrb, jclassobj, mobj);
  mobj = mrb_mruby_jni_wrap_jobject(mrb, mrb_class_ptr(mobj),  (*env)->NewLocalRef(env, jopt));
  mrb_funcall(mrb, mclass, "call", 3, mrb_fixnum_value(jtype), mrb_fixnum_value(jid), mobj);
  mrb_gc_arena_restore(mrb, ai);
  mrb_mruby_jni_check_exc(mrb);
}

void Java_com_github_wanabe_Andruboid_close(JNIEnv* env, jobject thiz, jint jmrb) {
  mrb_state *mrb = (mrb_state *)jmrb;
  mrb_close(mrb);
}

