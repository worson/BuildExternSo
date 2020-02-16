[TOC]
## 故事场景
android通常使用别人的轮子是直接依赖别人的aar，但是如果别人扔给你一个so和一个.h文件，我们需要如何使用，本工程将演示直接在ndk文件中链接so并在工程中使用。

# 编译库文件
## 工程结构
![](https://tva1.sinaimg.cn/large/0082zybpgy1gbym9vfdtlj30d105emxa.jpg)
## hello.h
提供 libhello.so和对应的.h文件 hello.h 如下
```
#ifndef HELLO_H 
#define HELLO_H 
#include <stdio.h> 
int HelloAdd(int a,int b);
#endif
```
其中 HelloAdd方法实现了a+b的操作，接下来将调用此函数实现功能。
## hello.cpp
```c
#include "hello.h"
int HelloAdd(int a,int b)
{
     int result=a+b;
     printf("HelloAdd:result=%d \n",result);
     return result;
}
```
## CmakeLists.txt
```
SET(LIBHELLO_SRC hello.cpp)

ADD_LIBRARY(hello SHARED ${LIBHELLO_SRC})
SET_TARGET_PROPERTIES(hello PROPERTIES VERSION 1.2 SOVERSION 1)

ADD_LIBRARY(hello_static STATIC ${LIBHELLO_SRC})
SET_TARGET_PROPERTIES(hello_static PROPERTIES OUTPUT_NAME "hello")
SET_TARGET_PROPERTIES(hello PROPERTIES CLEAN_DIRECT_OUTPUT 1)
SET_TARGET_PROPERTIES(hello_static PROPERTIES CLEAN_DIRECT_OUTPUT 1)

INSTALL(TARGETS hello hello_static
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)
INSTALL(FILES hello.h DESTINATION include/hello)
```
此示例是演示了动态和静态库两种编译方式

## 编译
模块下有一个脚本cmake_build_all.sh，直接在终端执行
`
cmake_build_all.sh libhello.so
`
则可输出以下文件：
![](https://tva1.sinaimg.cn/large/0082zybpgy1gbymebswuhj30bi0c3mxs.jpg)

注意：cmake_build_all.sh脚本信赖于环境变量ANDROID_SDK_PATH的配置，比如：
`
export ANDROID_SDK_PATH=/Users/Shared/ShareLib/Android/sdk
`



# 使用库文件

创建ndk工程

## 配置工程为cmake编译
在应用的build.gradle中配置

```
externalNativeBuild {
        cmake {
            path 'CMakeLists.txt'
        }
    }
```
当前目录创建CmakeLists.txt文件
```
cmake_minimum_required(VERSION 3.4.1)
add_subdirectory(src/main/cpp/jni)
```

在对应的“src/main/cpp/jni”文件下再创建以下文件

![](https://tva1.sinaimg.cn/large/0082zybpgy1gbpczmzjlaj309y09t74o.jpg)

其中CmakeLists.txt文件的内容为
```
cmake_minimum_required(VERSION 3.4.1)
add_library(math_test SHARED math_test.cc)
```

创建有native方法的java类MathTest
```
package com.sen.ndk.buildexternso;
public class MathTest {

    public static native int add(int a, int b);

    static {
        System.loadLibrary("math_test");
    }
}
```
因此需要定义Java_com_sen_ndk_buildexternso_MathTest_add方法

定义math_test.h文件

```
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

```
创建math_test.cc文件，目前还未使用so，直接返回相加值可测试工程运行
```

#include "math_test.h"

JNIEXPORT jint JNICALL Java_com_sen_ndk_buildexternso_MathTest_add
    (JNIEnv * env, jobject jo, jint a, jint b){

  return a+b;
}


```


# 使用hello.so文件

## 拷贝hello.h文件

```c
#ifndef HELLO_H 
#define HELLO_H 
#include <stdio.h> 
extern int HelloAdd(int a,int b); 
#endif
```

## 更新main.cpp
```
#include "hello.h"
int HelloAdd(int a,int b)
{
     int result=a+b;
     printf("HelloAdd:result=%d \n",result);
     return result;
}
```

## 更新cmake文件
``` c
cmake_minimum_required(VERSION 3.4.1)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../include)


add_library(hello SHARED IMPORTED)
set_target_properties(hello PROPERTIES IMPORTED_LOCATION
        ${PROJECT_LIBS_DIR}/${ANDROID_ABI}/libhello.so)

add_library(math_test SHARED math_test.cc)
target_include_directories(math_test PUBLIC ${hello_INCLUDE})
TARGET_LINK_LIBRARIES(math_test hello)
```
以上库的连接文件是动态连接，意味着当前工程就包连接hello库，也需要将hello库打包在工程中，因此需要将库文件拷贝到"src/main/jniLibs"目录下，至此整个依赖关系可完成。

