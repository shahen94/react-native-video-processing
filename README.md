#Library is under constructing

# react-native-video-processing

[![Build Status](https://travis-ci.org/shahen94/react-native-video-processing.svg?branch=master)](https://travis-ci.org/shahen94/react-native-video-processing) [![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg?style=plastic)](https://github.com/semantic-release/semantic-release) [![npm version](https://badge.fury.io/js/react-native-video-processing.svg)](https://badge.fury.io/js/react-native-video-processing)


## Getting started

`$ npm install react-native-video-processing --save`

### You can check test just running 
`$ npm test` or `$ yarn test`

### Manual installation


#### [iOS]

1. In Xcode, click the "Add Files to <your-project-name>".
2. Go to `node_modules` ➜ `react-native-video-processing` and add `RNVideoProcessing` directory.
3. Make sure `RNVideoProcessing` is "under" the "top-level" and then remove `GPUImage.xcodeproj` from `RNVideoProcessing` directory.
4. Add GPUImage.xcodeproj from `node_modules/react-native-video-processing/RNVideoProcessing` directory to your project and make sure it is "under" the "top-level":

    ![Project Structure](readme_assets/project-structure.png)

5. In XCode, in the project navigator, select your project.

   Add
    - CoreMedia
    - CoreVideo
    - OpenGLES
    - AVFoundation
    - QuartzCore
    - GPUImage
    - MobileCoreServices

    to your project's `Build Phases` ➜ `Link Binary With Libraries`.
6. import `RNVideoProcessing.h` into your `project_name-bridging-header.h`.
4. Clean and Run your project.

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

    trimVideo() {
        this.videoPlayerRef.trim(require('./videoFile.mp4'), startTime, endTime)
            .then((newSource) => console.log(newSource))
            .catch(console.warn)
    }

    render() {
        return (
            <View style={{ flex: 1 }}>
                <VideoPlayer
                    ref={ref => this.videoPlayerRef = ref}
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
                    height={100}
                    width={300}
                    themeColor={'white'}
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