package com.sen.ndk.buildexternso;

/**
 * 说明:
 *
 * @author wangshengxing  02.08 2020
 */
public class MathTest {

    public static native int add(int a, int b);

    static {
        System.loadLibrary("math_test");
    }
}
