package com.shahenlibrary.Events;

public enum EventsEnum {
    EVENT_PROGRESS("onVideoProgress");

    private final String mName;

    EventsEnum(final String name) {
        mName = name;
    }
    @Override
    public String toString() {
        return mName;
    }
}
