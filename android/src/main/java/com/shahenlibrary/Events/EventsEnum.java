package com.shahenlibrary.Events;

public enum EventsEnum {
    EVENT_PROGRESS("onVideoProgress"),
    EVENT_GET_INFO("getVideoInfo");

    private final String mName;

    EventsEnum(final String name) {
        mName = name;
    }
    @Override
    public String toString() {
        return mName;
    }
}
