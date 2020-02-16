
#include "math_test.h"
#include "hello.h"

JNIEXPORT jint JNICALL Java_com_sen_ndk_buildexternso_MathTest_add
    (JNIEnv * env, jobject jo, jint a, jint b){

  return HelloAdd(a,b);
//  return 1;
}

