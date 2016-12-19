## react-native-video-processing

 [![Build Status](https://travis-ci.org/shahen94/react-native-video-processing.svg?branch=master)](https://travis-ci.org/shahen94/react-native-video-processing) [![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg?style=plastic)](https://github.com/semantic-release/semantic-release) [![npm version](https://badge.fury.io/js/react-native-video-processing.svg)](https://badge.fury.io/js/react-native-video-processing)

### You can check test just running 
`$ npm test` or `$ yarn test`

### Manual installation


#### [iOS]

1. In Xcode, click the "Add Files to <your-project-name>".
2. Go to `node_modules` ➜ `react-native-video-processing/ios` and add `RNVideoProcessing` directory.
3. Make sure `RNVideoProcessing` is "under" the "top-level".
4. Add `GPUImage.xcodeproj` from `node_modules/react-native-video-processing/ios/GPUImage/framework` directory to your project and make sure it is "under" the "top-level":

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
6. Import `RNVideoProcessing.h` into your `project_name-bridging-header.h`.
7. Clean and Run your project.

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
        const options = {
            startTime: 0,
            endTime: 15,
            quality: VideoPlayer.Constants.quality.QUALITY_1280x720
        };
        this.videoPlayerRef.trim(require('./videoFile.mp4'), options)
            .then((newSource) => console.log(newSource))
            .catch(console.warn);
    }

    getPreviewImageForSecond(second) {
        const maximumSize = { width: 640, height: 1024 }; // default is { width: 1080, height: 1080 }
        this.videoPlayerRef.getPreviewForSecond(require('./videoFile.mp4'), second, maximumSize)
        .then((base64String) => console.log('This is BASE64 of image', base64String))
        .catch(console.warn);
    }

    getVideoInfo() {
        this.videoPlayerRef.getVideoInfo(require('./videoFile.mp4'))
        .then((info) => console.log(info))
        .catch(console.warn);
    }

    render() {
        return (
            <View style={{ flex: 1 }}>
                <VideoPlayer
                    ref={ref => this.videoPlayerRef = ref}
                    startTime={30}  // seconds
                    endTime={120}   // seconds
                    play={true}     // default false
                    replay={true}   // should player play video again if it's ended
                    rotate={true}   // use this prop to rotate video if it captured in landscape mode
                    source={require('./videoFile.mp4')}
                    playerWidth={300}
                    playerHeight={500}
                    style={{ backgroundColor: 'black' }}
                    onChange={({ nativeEvent }) => console.log({ nativeEvent })}
                />
                <Trimmer
                    source={require('./videoFile.mp4')}
                    height={100}
                    width={300}
                    currentTime={this.video.currentTime} // use this prop to set tracker position
                    themeColor={'white'}
                    trackerColor={'green'}
                    onChange={(e) => console.log(e.startTime, e.endTime)}
                />
            </View>
        );
    }
}
```

![dec-18-2016 17-59-39](https://cloud.githubusercontent.com/assets/13334788/21293985/3ae2af7a-c54c-11e6-8ae8-ddfc2db009f9.gif)

##Contributing

1. Please follow the eslint style guide.
2. Please commit with `$ npm run commit`
