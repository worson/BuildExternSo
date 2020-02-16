

#ifndef BUILDEXTERNSO_MATH_TEST_H
#define BUILDEXTERNSO_MATH_TEST_H
#include <jni.h>
#ifdef __cplusplus
extern "C" {
#endif

JNIEXPORT jint JNICALL Java_com_sen_ndk_buildexternso_MathTest_add
    (JNIEnv *, jobject, jint, jint);

#ifdef __cplusplus
}
#endif
#endif //BUILDEXTERNSO_MATH_TEST_H
