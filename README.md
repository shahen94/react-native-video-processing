#Library is under constructing

# react-native-video-processing

[![Build Status](https://travis-ci.org/shahen94/react-native-video-processing.svg?branch=master)](https://travis-ci.org/shahen94/react-native-video-processing) [![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg?style=plastic)](https://github.com/semantic-release/semantic-release) [![npm version](https://badge.fury.io/js/react-native-video-processing.svg)](https://badge.fury.io/js/react-native-video-processing)


## Getting started

`$ npm install react-native-video-processing --save`

### You can check test just running 
`$ npm test` or `$ yarn test`

### Manual installation


#### [iOS] This guide is not completed yet

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-video-processing` and add `RNVideoEditor.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNVideoEditor.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android version is not supported yet

## Usage
```javascript
import React, { Component } from 'react';
import { View } from 'react-native';
import { VideoPlayer, Trimmer } from 'react-native-video-processing';

class App extends Component {
    constructor(...args) {
        super(...args);
    }
    render() {
        return (
            <View style={{ flex: 1 }}>
                <VideoPlayer
                    startTime={30} // seconds
                    endTime={120} // seconds
                    play={true} // default false
                    source={require('./videoFile.mp4')}
                    playerWidth={300}
                    playerHeight={500}
                    style={{ backgroundColor: 'black' }}
                />
                <Trimmer
                    source={require('./videoFile.mp4')}
                    onChange={(e) => console.log(e.startTime, e.endTime)}
                />
            </View>
        );
    }
}
```

##Contributing

1. Please follow the eslint style guide.
2. Please commit with `$ npm run commit`
