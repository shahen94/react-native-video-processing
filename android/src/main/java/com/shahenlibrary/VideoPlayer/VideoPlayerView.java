package com.shahenlibrary.VideoPlayer;

import android.graphics.Matrix;
import android.media.MediaPlayer;
import android.net.Uri;
import android.util.Log;
import android.widget.MediaController;

import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.yqritc.scalablevideoview.ScalableVideoView;
import com.yqritc.scalablevideoview.ScaleManager;
import com.yqritc.scalablevideoview.Size;

import java.io.IOException;
import java.util.Objects;

public class VideoPlayerView extends ScalableVideoView implements
        MediaPlayer.OnPreparedListener, MediaPlayer.OnErrorListener, MediaPlayer.OnBufferingUpdateListener,
        MediaPlayer.OnCompletionListener, MediaPlayer.OnInfoListener, LifecycleEventListener, MediaController.MediaPlayerControl {

    private ThemedReactContext themedReactContext;
    private RCTEventEmitter eventEmitter;
    private String mediaSource;
    private String mediaType;
    private boolean playerPlaying = false;
    private String LOG_TAG = "RNVideoProcessing";

    public VideoPlayerView(ThemedReactContext ctx) {
        super(ctx);
        Log.d(LOG_TAG, "constructed");
        themedReactContext = ctx;
        eventEmitter = themedReactContext.getJSModule(RCTEventEmitter.class);
        themedReactContext.addLifecycleEventListener(this);
        initPlayerIfNeeded();
    }

    private void initPlayerIfNeeded() {
        if (mMediaPlayer != null) {
            return;
        }
        Log.d(LOG_TAG, "initPlayerIfNeeded");
        mMediaPlayer = new MediaPlayer();
        mMediaPlayer.setScreenOnWhilePlaying(true);
        mMediaPlayer.setOnVideoSizeChangedListener(this);
        mMediaPlayer.setOnErrorListener(this);
        mMediaPlayer.setOnPreparedListener(this);
        mMediaPlayer.setOnBufferingUpdateListener(this);
        mMediaPlayer.setOnCompletionListener(this);
        mMediaPlayer.setOnInfoListener(this);
    }

    public void setSrc(final String uriString) {
        if (mediaSource != null && mediaSource.equals(uriString)) {
            return;
        }
        reset();
        invalidate();

        mediaSource = uriString;
        Log.d(LOG_TAG, "set source: " + mediaSource);

        initPlayerIfNeeded();

        try {
            if (uriString.startsWith("content://")) {
                Uri parsedUri = Uri.parse(mediaSource);
                setDataSource(themedReactContext, parsedUri);
            } else {
                setDataSource(mediaSource);
            }
            prepare(this);

            if (playerPlaying && !mMediaPlayer.isPlaying()) {
                Log.d(LOG_TAG, "ERGI ARA");
                start();
            }

        } catch (IOException e) {
            e.printStackTrace();
            Log.d(LOG_TAG, "setSrc: ERROR");
        }
    }

    public void setPlay(final boolean shouldPlay) {
        Log.d(LOG_TAG, "setPlay: " + shouldPlay);
        playerPlaying = shouldPlay;

        if (mMediaPlayer == null) {
            Log.d(LOG_TAG, "setPlay: Player reference is null");
            return;
        }
        if (shouldPlay && !mMediaPlayer.isPlaying()) {
            start();
            Log.d(LOG_TAG, "setPlay: START");
        }
        if (!shouldPlay && mMediaPlayer.isPlaying()) {
            pause();
            Log.d(LOG_TAG, "setPlay: PAUSE");
        }
    }

    @Override
    public boolean onError(MediaPlayer mp, int what, int extra) {
        return false;
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);

        int videoWidth = getVideoWidth();
        int videoHeight = getVideoHeight();

        if (videoWidth == 0 || videoHeight == 0) {
            return;
        }
        Size viewSize = new Size(getWidth(), getHeight());
        Size videoSize = new Size(videoWidth, videoHeight);
        ScaleManager scaleManager = new ScaleManager(viewSize, videoSize);

        Matrix matrix = scaleManager.getScaleMatrix(mScalableType);
        if (matrix != null) {
            Log.d(LOG_TAG, "set transform");
            setTransform(matrix);
        }
    }

    @Override
    public void onPrepared(MediaPlayer mp) {

    }

    @Override
    public void onBufferingUpdate(MediaPlayer mp, int percent) {

    }

    @Override
    public void onCompletion(MediaPlayer mp) {

    }

    @Override
    public boolean onInfo(MediaPlayer mp, int what, int extra) {
        return false;
    }

    @Override
    public void onHostResume() {

    }

    @Override
    public void onHostPause() {

    }

    @Override
    public void onHostDestroy() {

    }

    @Override
    public int getBufferPercentage() {
        return 0;
    }

    @Override
    public boolean canPause() {
        return false;
    }

    @Override
    public boolean canSeekBackward() {
        return false;
    }

    @Override
    public boolean canSeekForward() {
        return false;
    }

    @Override
    public int getAudioSessionId() {
        return 0;
    }
}
