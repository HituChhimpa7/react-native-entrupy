package com.entrupy

import com.facebook.react.bridge.ReactApplicationContext

class EntrupyModule(reactContext: ReactApplicationContext) :
  NativeEntrupySpec(reactContext) {

  override fun multiply(a: Double, b: Double): Double {
    return a * b
  }

  companion object {
    const val NAME = NativeEntrupySpec.NAME
  }
}
