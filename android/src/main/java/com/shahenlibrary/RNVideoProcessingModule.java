
package com.shahenlibrary;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

public class RNVideoProcessingModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNVideoProcessingModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNVideoProcessing";
  }
}