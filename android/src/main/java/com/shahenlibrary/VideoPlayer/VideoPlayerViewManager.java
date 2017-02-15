package com.shahenlibrary.VideoPlayer;

import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.IllegalViewOperationException;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.shahenlibrary.Events.EventsEnum;
import com.shahenlibrary.Events.Events;

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

    private final int COMMAND_GET_INFO = 1;
    private final int COMMAND_TRIM_MEDIA = 2;
    private final int COMMAND_COMPRESS_MEDIA = 3;

    @Override
    public String getName() {
        return VideoPlayerViewManager.REACT_PACKAGE;
    }

    @Override
    protected VideoPlayerView createViewInstance(ThemedReactContext reactContext) {
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
                COMMAND_TRIM_MEDIA
        );
    }

    @Override
    public void receiveCommand(VideoPlayerView root, int commandId, @Nullable ReadableArray args) {
        switch (commandId) {
            case COMMAND_GET_INFO:
                root.sendMediaInfo();
                break;
            default:
                Log.d(VideoPlayerViewManager.REACT_PACKAGE, "receiveCommand: Wrong command received");
        }
    }

    @ReactProp(name = SET_SOURCE)
    public void setSource(final VideoPlayerView player, String source) {
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
        player.setLooping(replay);
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
    public void setVideoEndTime(final VideoPlayerView player, int endTime) {
        Log.d(VideoPlayerViewManager.REACT_PACKAGE, "setVideoEndTime: " + String.valueOf(endTime));
        player.setVideoEndAt(endTime);
    }

    @ReactProp(name = SET_VIDEO_START_TIME)
    public void setVideoStartTime(final VideoPlayerView player, int startTime) {
        Log.d(VideoPlayerViewManager.REACT_PACKAGE, "setVideoStartTime: " + String.valueOf(startTime));
        player.setVideoStartAt(startTime);
    }

    @ReactMethod
    public void getMediaInfo(Promise promise) {
        promise.resolve(10);
    }
}
