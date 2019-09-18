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
package com.shahenlibrary.utils;

import android.net.Uri;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import android.util.Log;

import com.coremedia.iso.boxes.Container;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.googlecode.mp4parser.FileDataSourceViaHeapImpl;
import com.googlecode.mp4parser.authoring.Movie;
import com.googlecode.mp4parser.authoring.Track;
import com.googlecode.mp4parser.authoring.builder.DefaultMp4Builder;
import com.googlecode.mp4parser.authoring.container.mp4.MovieCreator;
import com.googlecode.mp4parser.authoring.tracks.AppendTrack;
import com.googlecode.mp4parser.authoring.tracks.CroppedTrack;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.Formatter;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;

import com.shahenlibrary.Trimmer.Trimmer;
import com.shahenlibrary.interfaces.OnCompressVideoListener;
import com.shahenlibrary.interfaces.OnTrimVideoListener;


public class VideoEdit {

  private static final String TAG = "RNVideoEdit";

  public static boolean shouldUseURI(@Nullable String path) {
    String[] supportedProtocols = {
            "content://",
            "file://",
            "http://",
            "https://"
    };
    if (path == null) {
      return false;
    }
    boolean lookupWithURI = false;
    for (String protocol : supportedProtocols) {
      if (path.toLowerCase().startsWith(protocol)) {
        lookupWithURI = true;
        break;
      }
    }
    return lookupWithURI;
  }

  public static void startTrim(@NonNull File src, @NonNull String dst, long startMs, long endMs, @NonNull OnTrimVideoListener callback) throws IOException {
    final String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss_SSSS", Locale.US).format(new Date());
    final String fileName = "MP4_" + timeStamp + ".mp4";
    final String filePath = dst + fileName;

    Log.d(TAG, "startTrim: " + src.getAbsolutePath() + " isExists: " + src.exists());
    Log.d(TAG, "startTrim: filePath " + filePath);
    File file = new File(filePath);
    file.getParentFile().mkdirs();
    Log.d(TAG, "Generated file path " + filePath);
    genVideoUsingMp4Parser(src, file, startMs, endMs, callback);
  }

  public static void startCompress(@NonNull String source, @NonNull final OnCompressVideoListener callback, ThemedReactContext ctx, ReadableMap options) throws IOException {
    Trimmer.compress(source, options, null, callback, ctx, null);
  }

  private static void genVideoUsingMp4Parser(@NonNull File src, @NonNull File dst, long startMs, long endMs, @NonNull OnTrimVideoListener callback) throws IOException {
    if (!src.exists()) {
      String error = "Targeted video is not found";
      callback.onError(error);
      return;
    }
    Movie movie = MovieCreator.build(new FileDataSourceViaHeapImpl(src.getAbsolutePath()));

    Log.d(TAG, "genVideoUsingMp4Parser: Movie " + movie.toString());
    List<Track> tracks = movie.getTracks();
    movie.setTracks(new LinkedList<Track>());

    double startTime1 = startMs / 1000;
    double endTime1 = endMs / 1000;

    boolean timeCorrected = false;

    for (Track track : tracks) {
      if (track.getSyncSamples() != null && track.getSyncSamples().length > 0) {
        if (timeCorrected) {
          throw new RuntimeException("The startTime has already been corrected by another track with SyncSample. Not Supported.");
        }
        startTime1 = correctTimeToSyncSample(track, startTime1, false);
        endTime1 = correctTimeToSyncSample(track, endTime1, true);
        timeCorrected = true;
      }
    }

    for (Track track : tracks) {
      long currentSample = 0;
      double currentTime = 0;
      double lastTime = -1;
      long startSample1 = -1;
      long endSample1 = -1;

      for (int i = 0; i < track.getSampleDurations().length; i++) {
        long delta = track.getSampleDurations()[i];


        if (currentTime > lastTime && currentTime <= startTime1) {
          // current sample is still before the new starttime
          startSample1 = currentSample;
        }
        if (currentTime > lastTime && currentTime <= endTime1) {
          // current sample is after the new start time and still before the new endtime
          endSample1 = currentSample;
        }
        lastTime = currentTime;
        currentTime += (double) delta / (double) track.getTrackMetaData().getTimescale();
        currentSample++;
      }
      movie.addTrack(new AppendTrack(new CroppedTrack(track, startSample1, endSample1)));
    }

    Log.d(TAG, "genVideoUsingMp4Parser: get parent file");
    dst.getParentFile().mkdirs();

    if (!dst.exists()) {
      Log.d(TAG, "genVideoUsingMp4Parser: Create");
      dst.createNewFile();
    }

    Log.d(TAG, "genVideoUsingMp4Parser: created file");

    Container out = new DefaultMp4Builder().build(movie);

    FileOutputStream fos = new FileOutputStream(dst);
    FileChannel fc = fos.getChannel();
    out.writeContainer(fc);

    Log.d(TAG, "genVideoUsingMp4Parser: write and ready");
    fc.close();
    fos.close();

    Log.d(TAG, "genVideoUsingMp4Parser: closed streams");
    if (callback != null)
      callback.getResult(Uri.parse(dst.toString()));
  }

  private static double correctTimeToSyncSample(@NonNull Track track, double cutHere, boolean next) {
    double[] timeOfSyncSamples = new double[track.getSyncSamples().length];
    long currentSample = 0;
    double currentTime = 0;
    for (int i = 0; i < track.getSampleDurations().length; i++) {
      long delta = track.getSampleDurations()[i];

      if (Arrays.binarySearch(track.getSyncSamples(), currentSample + 1) >= 0) {
        timeOfSyncSamples[Arrays.binarySearch(track.getSyncSamples(), currentSample + 1)] = currentTime;
      }
      currentTime += (double) delta / (double) track.getTrackMetaData().getTimescale();
      currentSample++;

    }
    double previous = 0;
    for (double timeOfSyncSample : timeOfSyncSamples) {
      if (timeOfSyncSample > cutHere) {
        if (next) {
          return timeOfSyncSample;
        } else {
          return previous;
        }
      }
      previous = timeOfSyncSample;
    }
    return timeOfSyncSamples[timeOfSyncSamples.length - 1];
  }

  public static String stringForTime(int timeMs) {
    int totalSeconds = timeMs / 1000;

    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;

    Formatter mFormatter = new Formatter();
    if (hours > 0) {
      return mFormatter.format("%d:%02d:%02d", hours, minutes, seconds).toString();
    } else {
      return mFormatter.format("%02d:%02d", minutes, seconds).toString();
    }
  }

  public static Integer getIntFromString(String string) {
    int value;
    //check if int
    try {
      value = Integer.parseInt(string);
    } catch(Exception intException){
      //not int
      //check if float
      try {
        value = (int) Math.round(Float.parseFloat(string));
      } catch(Exception floatException){
        //not float
        return null;
      }
    }
    return value;
  }
}
