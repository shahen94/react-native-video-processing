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
import android.content.Context;
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
import com.facebook.react.uimanager.ThemedReactContext;
import com.shahenlibrary.Events.Events;
import com.shahenlibrary.interfaces.OnCompressVideoListener;
import com.shahenlibrary.interfaces.OnTrimVideoListener;
import com.shahenlibrary.utils.VideoEdit;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;

import wseemann.media.FFmpegMediaMetadataRetriever;

import java.util.UUID;
import java.io.FileOutputStream;
import java.util.Arrays;
import java.util.ArrayList;

import com.github.hiteshsondhi88.libffmpeg.FFmpeg;
import com.github.hiteshsondhi88.libffmpeg.FFmpegExecuteResponseHandler;
import com.github.hiteshsondhi88.libffmpeg.FFmpegLoadBinaryResponseHandler;


public class Trimmer {

  private static final String LOG_TAG = "RNTrimmerManager";

  private static boolean ffmpegLoaded;

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

      if(frame == null) {
        continue;
      }
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
    if (orientation == 90 || orientation == 270) {
      width = width + height;
      height = width - height;
      width = width - height;
    }

    WritableMap event = Arguments.createMap();
    WritableMap size = Arguments.createMap();

    size.putInt(Events.WIDTH, width);
    size.putInt(Events.HEIGHT, height);

    event.putMap(Events.SIZE, size);
    event.putInt(Events.DURATION, duration / 1000);
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

  public static void compress(String source, ReadableMap options, final Promise promise, final OnCompressVideoListener cb, ThemedReactContext tctx, ReactApplicationContext rctx) {
    Context ctx = tctx != null ? tctx : rctx;

    FFmpegMediaMetadataRetriever retriever = new FFmpegMediaMetadataRetriever();
    if (VideoEdit.shouldUseURI(source)) {
      retriever.setDataSource(ctx, Uri.parse(source));
    } else {
      retriever.setDataSource(source);
    }
    retriever.release();
    Log.d(LOG_TAG, "OPTIONS: " + options.toString());
    Double width = options.hasKey("width") ? options.getDouble("width") : null;
    Double height = options.hasKey("height") ? options.getDouble("height") : null;
    Double minimumBitrate = options.hasKey("minimumBitrate") ? options.getDouble("minimumBitrate") : null;
    Double bitrateMultiplier = options.hasKey("bitrateMultiplier") ? options.getDouble("bitrateMultiplier") : null;
    Boolean removeAudio = options.hasKey("removeAudio") ? options.getBoolean("removeAudio") : false;

    final File tempFile = createTempFile("mp4", promise, ctx);

    ArrayList<String> cmd = new ArrayList<String>();
    cmd.add("-y");
    cmd.add("-i");
    cmd.add(source);
    cmd.add("-c:v");
    cmd.add("libx264");
    if (width != null && height != null) {
      cmd.add("-vf");
      cmd.add("scale=" + Double.toString(width) + ":" + Double.toString(height));
    }

    cmd.add("-preset");
    cmd.add("ultrafast");
    cmd.add("-pix_fmt");
    cmd.add("yuv420p");

    if (removeAudio) {
      cmd.add("-an");
    }
    cmd.add(tempFile.getPath());

    final String[] cmdToExec = cmd.toArray( new String[0] );

    Log.d(LOG_TAG, Arrays.toString(cmdToExec));

    try {
      FFmpeg.getInstance(ctx).execute(cmdToExec, new FFmpegExecuteResponseHandler() {

        @Override
        public void onStart() {
          Log.d(LOG_TAG, "Compress: Start");
        }

        @Override
        public void onProgress(String message) {
        }

        @Override
        public void onFailure(String message) {
          if (cb != null) {
            cb.onError("compress error: failed. " + message);
          } else if (promise != null) {
            promise.reject("compress error: failed.", message);
          }
        }

        @Override
        public void onSuccess(String message) {
          if (cb != null) {
            cb.onSuccess("file://" + tempFile.getPath());
          } else if (promise != null) {
            WritableMap event = Arguments.createMap();
            event.putString("source", "file://" + tempFile.getPath());
            promise.resolve(event);
          }
        }

        @Override
        public void onFinish() {
          Log.d(LOG_TAG, "Compress: Finished");
        }
      });
    } catch (Exception e) {
      if (cb != null) {
        cb.onError("compress error. Command already running" + e.toString());
      } else if (promise != null) {
        promise.reject("compress error. Command already running", e.toString());
      }
    }
  }

  static File createTempFile(String extension, final Promise promise, Context ctx) {
    UUID uuid = UUID.randomUUID();
    String imageName = uuid.toString() + "-screenshot";

    File cacheDir = ctx.getCacheDir();
    File tempFile = null;
    try {
      tempFile = File.createTempFile(imageName, "." + extension, cacheDir);
    } catch( IOException e ) {
      promise.reject("Failed to create temp file", e.toString());
      return null;
    }

    if (tempFile.exists()) {
      tempFile.delete();
    }

    return tempFile;
  }

  static void getPreviewImageAtPosition(String source, double sec, String format, final Promise promise, ReactApplicationContext ctx) {
    FFmpegMediaMetadataRetriever metadataRetriever = new FFmpegMediaMetadataRetriever();
    FFmpegMediaMetadataRetriever.IN_PREFERRED_CONFIG = Bitmap.Config.ARGB_8888;
    metadataRetriever.setDataSource(source);

    Bitmap bmp = metadataRetriever.getFrameAtTime((long) (sec * 1000000));

    // NOTE: FIX ROTATED BITMAP
    int orientation = Integer.parseInt( metadataRetriever.extractMetadata(FFmpegMediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION) );
    metadataRetriever.release();

    if ( orientation != 0 ) {
      Matrix matrix = new Matrix();
      matrix.postRotate(orientation);
      bmp = Bitmap.createBitmap(bmp, 0, 0, bmp.getWidth(), bmp.getHeight(), matrix, true);
    }

    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();

    WritableMap event = Arguments.createMap();

    if ( format == null || (format != null && format.equals("base64")) ) {
      bmp.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
      byte[] byteArray = byteArrayOutputStream .toByteArray();
      String encoded = Base64.encodeToString(byteArray, Base64.DEFAULT);

      event.putString("image", encoded);
    } else if ( format.equals("JPEG") ) {
      bmp.compress(Bitmap.CompressFormat.JPEG, 100, byteArrayOutputStream);
      byte[] byteArray = byteArrayOutputStream.toByteArray();

      File tempFile = createTempFile("jpeg", promise, ctx);

      try {
        FileOutputStream fos = new FileOutputStream( tempFile.getPath() );

        fos.write( byteArray );
        fos.close();
      } catch (java.io.IOException e) {
        promise.reject("Failed to save image", e.toString());
        return;
      }

      WritableMap imageMap = Arguments.createMap();
      imageMap.putString("uri", "file://" + tempFile.getPath());

      event.putMap("image", imageMap);
    } else {
      promise.reject("Wrong format error", "Wrong 'format'. Expected one of 'base64' or 'JPEG'.");
      return;
    }

    promise.resolve(event);
  }

  static void crop(String source, ReadableMap options, final Promise promise, ReactApplicationContext ctx) {
    int cropWidth = (int)( options.getDouble("cropWidth") );
    int cropHeight = (int)( options.getDouble("cropHeight") );
    int cropOffsetX = (int)( options.getDouble("cropOffsetX") );
    int cropOffsetY = (int)( options.getDouble("cropOffsetY") );

    FFmpegMediaMetadataRetriever retriever = new FFmpegMediaMetadataRetriever();
    if (VideoEdit.shouldUseURI(source)) {
      retriever.setDataSource(ctx, Uri.parse(source));
    } else {
      retriever.setDataSource(source);
    }

    int videoWidth = Integer.parseInt(retriever.extractMetadata(FFmpegMediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH));
    int videoHeight = Integer.parseInt(retriever.extractMetadata(FFmpegMediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT));
    retriever.release();

    // NOTE: FFMpeg CROP NEED TO BE DEVIDED BY 2. OR YOU WILL SEE BLANK WHITE LINES FROM LEFT/RIGHT
    while( cropWidth % 2 > 0 && cropWidth < videoWidth ) {
      cropWidth += 1;
    }
    while( cropWidth % 2 > 0 && cropWidth > 0 ) {
      cropWidth -= 1;
    }
    while( cropHeight % 2 > 0 && cropHeight < videoHeight ) {
      cropHeight += 1;
    }
    while( cropHeight % 2 > 0 && cropHeight > 0 ) {
      cropHeight -= 1;
    }

    // TODO: 1) ADD METHOD TO CHECK "IS FFMPEG LOADED".
    // 2) CHECK IT HERE
    // 3) EXPORT THAT METHOD TO "JS"

    final File tempFile = createTempFile("mp4", promise, ctx);

    ArrayList<String> cmd = new ArrayList<String>();
    cmd.add("-y"); // NOTE: OVERWRITE OUTPUT FILE

    String startTime = options.getString("startTime");
    if ( !startTime.equals(null) && !startTime.equals("") ) {
      cmd.add("-ss");
      cmd.add(startTime);
    }

    // NOTE: INPUT FILE
    cmd.add("-i");
    cmd.add(source);

    String endTime = options.getString("endTime");
    if ( !endTime.equals(null) && !endTime.equals("") ) {
      cmd.add("-to");
      cmd.add(endTime);
    }

    cmd.add("-vf");
    cmd.add("crop=" + Integer.toString(cropWidth) + ":" + Integer.toString(cropHeight) + ":" + Integer.toString(cropOffsetX) + ":" + Integer.toString(cropOffsetY));

    cmd.add("-preset");
    cmd.add("ultrafast");
    // NOTE: DO NOT CONVERT AUDIO TO SAVE TIME
    cmd.add("-c:a");
    cmd.add("copy");
    // NOTE: FLAG TO CONVER "AAC" AUDIO CODEC
    cmd.add("-strict");
    cmd.add("-2");
    // NOTE: OUTPUT FILE
    cmd.add(tempFile.getPath());

    final String[] cmdToExec = cmd.toArray( new String[0] );

    Log.d(LOG_TAG, Arrays.toString(cmdToExec));

    try {
      FFmpeg.getInstance(ctx).execute(cmdToExec, new FFmpegExecuteResponseHandler() {

        @Override
        public void onStart() {
          Log.d(LOG_TAG, "crop: onStart");
        }

        @Override
        public void onProgress(String message) {
          Log.d(LOG_TAG, "crop: onProgress");
        }

        @Override
        public void onFailure(String message) {
          Log.d(LOG_TAG, "crop: onFailure");
          promise.reject("Crop error: failed.", message);
        }

        @Override
        public void onSuccess(String message) {
          Log.d(LOG_TAG, "crop: onSuccess");
          Log.d(LOG_TAG, message);

          WritableMap event = Arguments.createMap();
          event.putString("source", "file://" + tempFile.getPath());
          promise.resolve(event);
        }

        @Override
        public void onFinish() {
          Log.d(LOG_TAG, "crop: onFinish");
        }
      });
    } catch (Exception e) {
      promise.reject("Crop error. Command already running", e.toString());
    }
  }

  public static void loadFfmpeg(ReactApplicationContext ctx){
    try {
      FFmpeg.getInstance(ctx).loadBinary(new FFmpegLoadBinaryResponseHandler() {
        @Override
        public void onStart() {
          Log.d(LOG_TAG, "load FFMPEG: onStart");
        }

        @Override
        public void onSuccess() {
          Log.d(LOG_TAG, "load FFMPEG: onSuccess");
          ffmpegLoaded = true;
        }

        @Override
        public void onFailure() {
          ffmpegLoaded = false;
          Log.d(LOG_TAG, "load FFMPEG: Failed to load ffmpeg");
        }

        @Override
        public void onFinish() {
          Log.d(LOG_TAG, "load FFMPEG: onFinish");
        }
      });
    } catch (Exception e){
      ffmpegLoaded = false;
      Log.d("Failed to load ffmpeg", e.toString());
    }
  }
}
