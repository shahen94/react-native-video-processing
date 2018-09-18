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
package com.shahenlibrary.VideoPlayer;

import android.util.Log;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.shahenlibrary.Events.EventsEnum;
import com.shahenlibrary.Events.Events;
import com.yqritc.scalablevideoview.ScalableType;

import java.util.Map;

import javax.annotation.Nullable;

public class VideoPlayerViewManager extends SimpleViewManager<VideoPlayerView> {
  private static final String REACT_PACKAGE = "RNVideoProcessing";
  private final String SET_SOURCE = "source";
  private final String SET_PLAY = "play";
  private final String SET_REPLAY = "replay";
  private final String SET_VOLUME = "volume";
  private final String SET_CURRENT_TIME = "currentTime";
  private final String SET_PROGRESS_DELAY = "progressEventDelay";
  private final String SET_VIDEO_END_TIME = "endTime";
  private final String SET_VIDEO_START_TIME = "startTime";
  private final String SET_VIDEO_RESIZE_MODE = "resizeMode";

  private final int COMMAND_GET_INFO = 1;
  private final int COMMAND_TRIM_MEDIA = 2;
  private final int COMMAND_COMPRESS_MEDIA = 3;
  private final int COMMAND_GET_PREVIEW_IMAGE = 4;

  private ThemedReactContext reactContext;

  @Override
  public String getName() {
    return VideoPlayerViewManager.REACT_PACKAGE;
  }

  @Override
  protected VideoPlayerView createViewInstance(ThemedReactContext reactContext) {
    this.reactContext = reactContext;
    return new VideoPlayerView(reactContext);
  }

  @Override
  public void onDropViewInstance(VideoPlayerView player) {
    super.onDropViewInstance(player);
    player.cleanup();
  }

  @Nullable
  @Override
  public Map getExportedCustomDirectEventTypeConstants() {
    MapBuilder.Builder<String, Map> builder = MapBuilder.builder();
    for (EventsEnum evt : EventsEnum.values()) {
      builder.put(evt.toString(), MapBuilder.of("registrationName", evt.toString()));
    }
    Log.d(VideoPlayerViewManager.REACT_PACKAGE, builder.toString());
    return builder.build();
  }

  @Nullable
  @Override
  public Map<String, Integer> getCommandsMap() {
    Log.d(VideoPlayerViewManager.REACT_PACKAGE, "getCommandsMap");
    return MapBuilder.of(
            Events.COMPRESS_MEDIA,
            COMMAND_COMPRESS_MEDIA,

            Events.GET_MEDIA_INFO,
            COMMAND_GET_INFO,

            Events.TRIM_MEDIA,
            COMMAND_TRIM_MEDIA,

            Events.GET_PREVIEW_IMAGE,
            COMMAND_GET_PREVIEW_IMAGE
    );
  }

  @Nullable
  @Override
  public Map getExportedViewConstants() {
    return MapBuilder.of(
            "ScaleNone", Integer.toString(ScalableType.LEFT_TOP.ordinal()),
            "ScaleToFill", Integer.toString(ScalableType.FIT_XY.ordinal()),
            "ScaleAspectFit", Integer.toString(ScalableType.FIT_CENTER.ordinal()),
            "ScaleAspectFill", Integer.toString(ScalableType.CENTER_CROP.ordinal())
    );
  }

  @Override
  public void receiveCommand(VideoPlayerView root, int commandId, @Nullable ReadableArray args) {
    assert args != null;
    Log.d(VideoPlayerViewManager.REACT_PACKAGE, "receiveCommand: " + args.toString());
    Log.d(VideoPlayerViewManager.REACT_PACKAGE, "receiveCommand: commandId " + String.valueOf(commandId));
    switch (commandId) {
      case COMMAND_GET_INFO:
        root.sendMediaInfo();
        break;
      case COMMAND_TRIM_MEDIA:
        double startAt = args.getDouble(0);
        double endAt = args.getDouble(1);
        root.trimMedia(startAt, endAt);
        break;
      case COMMAND_GET_PREVIEW_IMAGE:
        float sec = (float) args.getDouble(0);
        Log.d(VideoPlayerViewManager.REACT_PACKAGE, "receiveCommand: Get Preview image for sec: " + sec);
        root.getFrame(sec);
        break;
      case COMMAND_COMPRESS_MEDIA:
        ReadableMap options = args.getMap(0);
        root.compressMedia(this.reactContext, options);
        break;
      default:
        Log.d(VideoPlayerViewManager.REACT_PACKAGE, "receiveCommand: Wrong command received");
    }
  }

  @ReactProp(name = SET_SOURCE)
  public void setSource(final VideoPlayerView player, @Nullable String source) {
    if (source == null) {
      return;
    }
    player.setSource(source);
  }

  @ReactProp(name = SET_PLAY, defaultBoolean = true)
  public void setPlay(final VideoPlayerView player, boolean shouldPlay) {
    Log.d(VideoPlayerViewManager.REACT_PACKAGE, "setPlay: " + String.valueOf(shouldPlay));
    player.setPlay(shouldPlay);
  }

  @ReactProp(name = SET_REPLAY, defaultBoolean = true)
  public void setReplay(final VideoPlayerView player, boolean replay) {
    Log.d(VideoPlayerViewManager.REACT_PACKAGE, "set replay: " + String.valueOf(replay));
    player.setRepeat(replay);
  }

  @ReactProp(name = SET_VOLUME, defaultFloat = 10f)
  public void setVolume(final VideoPlayerView player, float volume) {
    Log.d(VideoPlayerViewManager.REACT_PACKAGE, "set volume: " + String.valueOf(volume));
    player.setMediaVolume(volume);
  }

  @ReactProp(name = SET_CURRENT_TIME, defaultFloat = 0f)
  public void setCurrentTime(final VideoPlayerView player, float seekTime) {
    Log.d(VideoPlayerViewManager.REACT_PACKAGE, "set current time: " + String.valueOf(seekTime) );
    player.setCurrentTime(seekTime);
  }

  @ReactProp(name = SET_PROGRESS_DELAY, defaultInt = 1000)
  public void setProgressDelay(final VideoPlayerView player, int delay) {
    player.setProgressUpdateHandlerDelay(delay);
  }

  @ReactProp(name = SET_VIDEO_END_TIME)
  public void setVideoEndTime(final VideoPlayerView player, float endTime) {
    int mEnd = (int) endTime;
    Log.d(VideoPlayerViewManager.REACT_PACKAGE, "setVideoEndTime: " + String.valueOf(endTime));
    player.setVideoEndAt(mEnd);
  }

  @ReactProp(name = SET_VIDEO_START_TIME)
  public void setVideoStartTime(final VideoPlayerView player, float startTime) {
    int mStart = (int) startTime;
    Log.d(VideoPlayerViewManager.REACT_PACKAGE, "setVideoStartTime: " + String.valueOf(startTime));
    player.setVideoStartAt(mStart);
  }

  @ReactProp(name = SET_VIDEO_RESIZE_MODE)
  public void setResizeMode(final VideoPlayerView player, String resizeModeOrdinalString) {
    player.setResizeMode(ScalableType.values()[Integer.parseInt(resizeModeOrdinalString)]);
  }
}
