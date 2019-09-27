/*
 * MIT License
 *
 * Copyright (c) 2017 Shahen Hovhannisyan.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package com.shahenlibrary.Trimmer;

import androidx.annotation.NonNull;
import android.util.Log;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.common.MapBuilder;

import java.util.Map;

public class TrimmerManager extends ReactContextBaseJavaModule {
  static final String REACT_PACKAGE = "RNTrimmerManager";

  private final ReactApplicationContext reactContext;

  public TrimmerManager(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    loadFfmpeg();
  }

  @Override
  public String getName() {
    return REACT_PACKAGE;
  }

  @ReactMethod
  public void getPreviewImages(String path, Promise promise) {
    Log.d(REACT_PACKAGE, "getPreviewImages: " + path);
    Trimmer.getPreviewImages(path, promise, reactContext);
  }

  @ReactMethod
  public void getVideoInfo(String path, Promise promise) {
    Log.d(REACT_PACKAGE, "getVideoInfo: " + path);
    Trimmer.getVideoInfo(path, promise, reactContext);
  }

  @ReactMethod
  public void trim(ReadableMap options, Promise promise) {
    Log.d(REACT_PACKAGE, options.toString());
    Trimmer.trim(options, promise, reactContext);
  }

  @ReactMethod
  public void compress(String path, ReadableMap options, Promise promise) {
    Log.d(REACT_PACKAGE, "compress video: " + options.toString());
    Trimmer.compress(path, options, promise, null, null, reactContext);
  }

  @ReactMethod
  public void getPreviewImageAtPosition(ReadableMap options, Promise promise) {
    String source = options.getString("source");
    double sec = options.hasKey("second") ? options.getDouble("second") : 0;
    String format = options.hasKey("format") ? options.getString("format") : null;
    Trimmer.getPreviewImageAtPosition(source, sec, format, promise, reactContext);
  }

  @ReactMethod
  public void getTrimmerPreviewImages(ReadableMap options, Promise promise) {
    String source = options.getString("source");
    double startTime = options.hasKey("startTime") ? options.getDouble("startTime") : 0;
    double endTime = options.hasKey("endTime") ? options.getDouble("endTime") : 0;
    int step = options.hasKey("step") ? options.getInt("step") : 0;
    String format = options.hasKey("format") ? options.getString("format") : null;
    Trimmer.getTrimmerPreviewImages(source, startTime, endTime, step, format, promise, reactContext);
  }

  @ReactMethod
  public void crop(String path, ReadableMap options, Promise promise) {
    Trimmer.crop(path, options, promise, reactContext);
  }

  @ReactMethod
  public void boomerang(String path, Promise promise) {
    Log.d(REACT_PACKAGE, "boomerang video: " + path);
    Trimmer.boomerang(path, promise, reactContext);
  }

  @ReactMethod
  public void reverse(String path, Promise promise) {
    Log.d(REACT_PACKAGE, "reverse video: " + path);
    Trimmer.reverse(path, promise, reactContext);
  }

  @ReactMethod
  public void merge(ReadableArray videoFiles, String cmd, Promise promise) {
    Log.d(REACT_PACKAGE, "Sending command: " + cmd);
    Trimmer.merge(videoFiles, cmd, promise, reactContext);
  }

  @ReactMethod
  private void loadFfmpeg() {
    Trimmer.loadFfmpeg(reactContext);
  }
}
