package com.shahenlibrary.VideoPlayer;

import android.util.Log;

import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;

public class VideoPlayerViewManager extends SimpleViewManager<VideoPlayerView> {
    private final String REACT_PACKAGE = "RNVideoProcessing";
    private final String SET_SOURCE = "src";
    private final String SET_PLAY = "play";

    @Override
    public String getName() {
        return REACT_PACKAGE;
    }

    @Override
    protected VideoPlayerView createViewInstance(ThemedReactContext reactContext) {
        return new VideoPlayerView(reactContext);
    }

    @ReactProp(name = SET_SOURCE)
    public void setSource(final VideoPlayerView player, String source) {
        player.setSrc(source);
    }

    @ReactProp(name = SET_PLAY)
    public void setPlay(final VideoPlayerView player, boolean shouldPlay) {
        Log.d("RNVideoProcessing", "setPlay");
        player.setPlay(shouldPlay);
    }
}
