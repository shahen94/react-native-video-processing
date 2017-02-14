package com.shahenlibrary.VideoPlayer;

import android.util.Log;

import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.shahenlibrary.Events.EventsEnum;

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
}
