package com.entrupy

import android.util.Log
import com.entrupy.sdk.app.EntrupyApp
import com.entrupy.sdk.listeners.CaptureCallback
import com.entrupy.sdk.listeners.SdkLoginCallback
import com.entrupy.sdk.model.METADATA_KEY_BRAND
import com.entrupy.sdk.model.METADATA_KEY_CUSTOMER_ITEM_ID
import com.entrupy.sdk.model.METADATA_KEY_ITEM_TYPE
import com.entrupy.sdk.model.METADATA_KEY_PRODUCT_CATEGORY
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod

private const val TAG = "EntrupyModule"

class EntrupyModule(reactContext: ReactApplicationContext) :
  NativeEntrupySpec(reactContext) {

  init {
      val app = reactContext.applicationContext as? android.app.Application
      if (app != null) {
          try {
              EntrupyApp.init(app)
              Log.d(TAG, "EntrupyApp initialized successfully in module.")
          } catch (e: Exception) {
              Log.e(TAG, "EntrupyApp.init failed", e)
          }
      } else {
          Log.e(TAG, "Failed to get Application context for EntrupyApp.init")
      }
  }

  override fun getName() = NAME

  @ReactMethod
  override fun generateAuthorizationRequest(promise: Promise) {
      try {
          val request = EntrupyApp.sharedInstance().generateSDKAuthorizationRequest()
          Log.d(TAG, "Auth request generated: ${request.take(50)}...")
          promise.resolve(request)
      } catch (e: Exception) {
          Log.e(TAG, "generateAuthorizationRequest error", e)
          promise.reject("AUTH_REQUEST_ERROR", e.message ?: "Failed to generate auth request")
      }
  }

  @ReactMethod
  override fun loginUser(signedRequest: String, promise: Promise) {
      try {
          EntrupyApp.sharedInstance().loginUser(
              signedRequest = signedRequest,
              callback = object : SdkLoginCallback {
                  override fun onLoginStarted() {
                      Log.d(TAG, "SDK login started")
                  }

                  override fun onLoginSuccess(expirationTime: Long) {
                      Log.d(TAG, "SDK login success, expires: $expirationTime")
                      promise.resolve(true)
                  }

                  override fun onLoginError(
                      errorCode: Int,
                      description: String,
                      localizedDescription: String
                  ) {
                      Log.e(TAG, "SDK login error: $description (Code: $errorCode)")
                      promise.reject(errorCode.toString(), localizedDescription)
                  }
              }
          )
      } catch (e: Exception) {
          Log.e(TAG, "loginUser error", e)
          promise.reject("LOGIN_ERROR", e.message ?: "Login failed")
      }
  }

  @ReactMethod
  override fun startCapture(productCategory: String, brand: String, itemType: String, itemId: String, promise: Promise) {
      val activity = currentActivity ?: run {
          promise.reject("NO_ACTIVITY", "No current activity found")
          return
      }

      activity.runOnUiThread {
          try {
              val metadata = buildMap<String, Any?> {
                  if (productCategory.isNotBlank()) {
                      put(METADATA_KEY_PRODUCT_CATEGORY, productCategory.lowercase().trim())
                  }
                  put(METADATA_KEY_BRAND, brand.lowercase().trim())
                  if (itemType.isNotBlank()) {
                      put(METADATA_KEY_ITEM_TYPE, itemType.lowercase().trim())
                  }
                  if (itemId.isNotBlank()) {
                      put(METADATA_KEY_CUSTOMER_ITEM_ID, itemId)
                  }
              }

              EntrupyApp.sharedInstance().startCapture(
                  configMetadata = metadata,
                  callback = object : CaptureCallback {
                      override fun onCaptureStarted() {
                          Log.d(TAG, "Capture started for brand: $brand")
                          promise.resolve(true)
                      }

                      override fun onCaptureError(errorCode: Int, description: String) {
                          Log.e(TAG, "Capture error: $description (Code: $errorCode)")
                          promise.reject(errorCode.toString(), description)
                      }
                  }
              )
          } catch (e: Exception) {
              Log.e(TAG, "startCapture error", e)
              promise.reject("CAPTURE_ERROR", e.message ?: "Capture failed")
          }
      }
  }

  companion object {
    const val NAME = NativeEntrupySpec.NAME
  }
}
