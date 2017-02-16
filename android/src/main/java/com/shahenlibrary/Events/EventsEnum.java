package com.shahenlibrary.Events;

public enum EventsEnum {
    EVENT_PROGRESS("onVideoProgress"),
    EVENT_GET_PREVIEW_IMAGE("getPreviewImage"),
    EVENT_GET_INFO("getVideoInfo"),
    EVENT_GET_TRIMMED_SOURCE("getTrimmedSource"),
    EVENT_GET_COMPRESSED_SOURCE("getCompressedSource");

    private final String mName;

    EventsEnum(final String name) {
        mName = name;
    }
    @Override
    public String toString() {
        return mName;
    }
}
