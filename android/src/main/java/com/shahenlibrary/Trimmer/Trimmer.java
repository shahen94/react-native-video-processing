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

import android.annotation.TargetApi;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.os.Build;
import android.util.Base64;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.Event;
import com.shahenlibrary.Events.Events;
import com.shahenlibrary.Events.EventsEnum;
import com.shahenlibrary.interfaces.OnTrimVideoListener;
import com.shahenlibrary.utils.VideoEdit;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;

import wseemann.media.FFmpegMediaMetadataRetriever;

public class Trimmer {

  private static final String LOG_TAG = "RNTrimmerManager";

  public static void getPreviewImages(String path, Promise promise, ReactApplicationContext ctx) {
    FFmpegMediaMetadataRetriever retriever = new FFmpegMediaMetadataRetriever();
    if (VideoEdit.shouldUseURI(path)) {
      retriever.setDataSource(ctx, Uri.parse(path));
    } else {
      retriever.setDataSource(path);
    }

    WritableArray images = Arguments.createArray();
    int duration = Integer.parseInt(retriever.extractMetadata(FFmpegMediaMetadataRetriever.METADATA_KEY_DURATION));
    int width = Integer.parseInt(retriever.extractMetadata(FFmpegMediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH));
    int height = Integer.parseInt(retriever.extractMetadata(FFmpegMediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT));
    int orientation = Integer.parseInt(retriever.extractMetadata(FFmpegMediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION));

    float aspectRatio = width / height;

    int resizeWidth = 200;
    int resizeHeight = Math.round(resizeWidth / aspectRatio);

    float scaleWidth = ((float) resizeWidth) / width;
    float scaleHeight = ((float) resizeHeight) / height;

    Log.d(TrimmerManager.REACT_PACKAGE, "getPreviewImages: \n\tduration: " + duration +
      "\n\twidth: " + width +
      "\n\theight: " + height +
      "\n\torientation: " + orientation +
      "\n\taspectRatio: " + aspectRatio +
      "\n\tresizeWidth: " + resizeWidth +
      "\n\tresizeHeight: " + resizeHeight
    );

    Matrix mx = new Matrix();

    mx.postScale(scaleWidth, scaleHeight);
    mx.postRotate(orientation - 360);

    for (int i = 0; i < duration; i += duration / 10) {
      Bitmap frame = retriever.getFrameAtTime(i * 1000);
      Bitmap currBmp = Bitmap.createScaledBitmap(frame, resizeWidth, resizeHeight, false);

      Bitmap normalizedBmp = Bitmap.createBitmap(currBmp, 0, 0, resizeWidth, resizeHeight, mx, true);
      ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
      normalizedBmp.compress(Bitmap.CompressFormat.PNG, 90, byteArrayOutputStream);
      byte[] byteArray = byteArrayOutputStream .toByteArray();
      String encoded = "data:image/png;base64," + Base64.encodeToString(byteArray, Base64.DEFAULT);
      images.pushString(encoded);
    }

    WritableMap event = Arguments.createMap();

    event.putArray("images", images);

    promise.resolve(event);
    retriever.release();
  }

  @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
  public static void getVideoInfo(String path, Promise promise, ReactApplicationContext ctx) {
    FFmpegMediaMetadataRetriever mmr = new FFmpegMediaMetadataRetriever();

    if (VideoEdit.shouldUseURI(path)) {
      mmr.setDataSource(ctx, Uri.parse(path));
    } else {
      mmr.setDataSource(path);
    }

    int duration = Integer.parseInt(mmr.extractMetadata(FFmpegMediaMetadataRetriever.METADATA_KEY_DURATION));
    int width = Integer.parseInt(mmr.extractMetadata(FFmpegMediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH));
    int height = Integer.parseInt(mmr.extractMetadata(FFmpegMediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT));
    int orientation = Integer.parseInt(mmr.extractMetadata(FFmpegMediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION));

    WritableMap event = Arguments.createMap();
    event.putInt(Events.DURATION, duration);
    event.putInt(Events.WIDTH, width);
    event.putInt(Events.HEIGHT, height);
    event.putInt(Events.ORIENTATION, orientation);

    promise.resolve(event);

    mmr.release();
  }

  static void trim(ReadableMap options, final Promise promise) {
    double startMs = options.getDouble("startTime");
    double endMs = options.getDouble("endTime");
    String mediaSource = options.getString("source");

    OnTrimVideoListener trimVideoListener = new OnTrimVideoListener() {
      @Override
      public void onError(String message) {
        Log.d(LOG_TAG, "Trimmed onError: " + message);
        WritableMap event = Arguments.createMap();
        event.putString(Events.ERROR_TRIM, message);

        promise.reject("trim error", message);
      }

      @Override
      public void onTrimStarted() {
        Log.d(LOG_TAG, "Trimmed onTrimStarted");
      }

      @Override
      public void getResult(Uri uri) {
        Log.d(LOG_TAG, "getResult: " + uri.toString());
        WritableMap event = Arguments.createMap();
        event.putString("source", uri.toString());
        promise.resolve(event);
      }

      @Override
      public void cancelAction() {
        Log.d(LOG_TAG, "Trimmed cancelAction");
      }
    };
    Log.d(LOG_TAG, "trimMedia at : startAt -> " + startMs + " : endAt -> " + endMs);
    File mediaFile = new File(mediaSource.replace("file:///", "/"));
    long startTrimFromPos = (long) startMs * 1000;
    long endTrimFromPos = (long) endMs * 1000;
    String[] dPath = mediaSource.split("/");
    StringBuilder builder = new StringBuilder();
    for (int i = 0; i < dPath.length; ++i) {
      if (i == dPath.length - 1) {
        continue;
      }
      builder.append(dPath[i]);
      builder.append(File.separator);
    }
    String path = builder.toString().replace("file:///", "/");

    Log.d(LOG_TAG, "trimMedia: " + mediaFile.toString() + " isExists: " + mediaFile.exists());
    try {
      VideoEdit.startTrim(mediaFile, path, startTrimFromPos, endTrimFromPos, trimVideoListener);
    } catch (IOException e) {
      trimVideoListener.onError(e.toString());
      e.printStackTrace();
      Log.d(LOG_TAG, "trimMedia: error -> " + e.toString());
    }
  }

  static void getPreviewAtPosition(String source, double sec, final Promise promise) {
    FFmpegMediaMetadataRetriever metadataRetriever = new FFmpegMediaMetadataRetriever();
    metadataRetriever.setDataSource(source);

    Bitmap bmp = metadataRetriever.getFrameAtTime((long) (sec * 1000000));
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    bmp.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
    byte[] byteArray = byteArrayOutputStream .toByteArray();
    String encoded = Base64.encodeToString(byteArray, Base64.DEFAULT);

    WritableMap event = Arguments.createMap();
    event.putString("image", encoded);

    promise.resolve(event);
  }
}
