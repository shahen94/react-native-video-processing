## react-native-video-processing

 [![Build Status](https://travis-ci.org/shahen94/react-native-video-processing.svg?branch=master)](https://travis-ci.org/shahen94/react-native-video-processing) [![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg?style=plastic)](https://github.com/semantic-release/semantic-release) [![npm version](https://badge.fury.io/js/react-native-video-processing.svg)](https://badge.fury.io/js/react-native-video-processing) ![npm package](https://img.shields.io/npm/dm/react-native-video-processing.svg)

### Getting Started
```sh
npm install react-native-video-processing --save
```
### You can check test just running
`$ npm test` or `$ yarn test`

### Manual installation

**Note: For RN 0.4x use 1.0 version, For RN 0.3x use  0.16**
#### [Android]
1. Open up `android/app/src/main/java/[...]/MainApplication.java`

2. Add `import com.shahenlibrary.RNVideoProcessingPackage;` to the imports at the top of the file

3. Add new  `new RNVideoProcessingPackage()`  to the list returned by the getPackages() method

4. Append the following lines to `android/settings.gradle`:
```
include ':react-native-video-processing'
project(':react-native-video-processing').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-video-processing/android')
```

5. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
```
    compile project(':react-native-video-processing')
```

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

## Usage
```javascript
import React, { Component } from 'react';
import { View } from 'react-native';
import { VideoPlayer, Trimmer } from 'react-native-video-processing';

class App extends Component {
    trimVideo() {
        const options = {
            startTime: 0,
            endTime: 15,
            quality: VideoPlayer.Constants.quality.QUALITY_1280x720, // iOS only
            saveToCameraRoll: true, // default is false // iOS only
            saveWithCurrentDate: true, // default is false // iOS only
        };
        this.videoPlayerRef.trim(options)
            .then((newSource) => console.log(newSource))
            .catch(console.warn);
    }

    compressVideo() {
        const options = {
            width: 720,
            height: 1280,
            bitrateMultiplier: 3, // iOS only
            saveToCameraRoll: true, // default is false, iOS only
            saveWithCurrentDate: true, // default is false, iOS only
            minimumBitrate: 300000, // iOS only
            removeAudio: true, // default is false
        };
        this.videoPlayerRef.compress(options)
            .then((newSource) => console.log(newSource))
            .catch(console.warn);
    }

    getPreviewImageForSecond(second) {
        const maximumSize = { width: 640, height: 1024 }; // default is { width: 1080, height: 1080 } iOS only
        this.videoPlayerRef.getPreviewForSecond(second, maximumSize) // maximumSize is iOS only
        .then((base64String) => console.log('This is BASE64 of image', base64String))
        .catch(console.warn);
    }

    getVideoInfo() {
        this.videoPlayerRef.getVideoInfo()
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
                    rotate={true}   // use this prop to rotate video if it captured in landscape mode iOS only
                    source={'file:///sdcard/DCIM/....'}
                    playerWidth={300} // iOS only
                    playerHeight={500} // iOS only
                    style={{ backgroundColor: 'black' }}
                    resizeMode={VideoPlayer.Constants.resizeMode.CONTAIN}
                    onChange={({ nativeEvent }) => console.log({ nativeEvent })} // get Current time on every second
                />
                <Trimmer
                    source={'file:///sdcard/DCIM/....'}
                    height={100}
                    width={300}
                    onTrackerMove={(e) => console.log(e.currentTime)} // iOS only
                    currentTime={this.video.currentTime} // use this prop to set tracker position iOS only
                    themeColor={'white'} // iOS only
                    thumbWidth={30} // iOS only
                    trackerColor={'green'} // iOS only
                    onChange={(e) => console.log(e.startTime, e.endTime)}
                />
            </View>
        );
    }
}
```
or you can use ProcessingManager without mounting VideoPlayer component
```javascript
import React, { Component } from 'react';
import { View } from 'react-native';
import { ProcessingManager } from 'react-native-video-processing';
export class App extends Component {
  componentWillMount() {
    const { source } = this.props;
    ProcessingManager.getVideoInfo(source)
      .then(({ duration, size }) => console.log(duration, size));

    ProcessingManager.trim(source, options) // like VideoPlayer trim options
          .then((data) => console.log(data));

    ProcessingManager.compress(source, options) // like VideoPlayer compress options
              .then((data) => console.log(data));

    const maximumSize = { width: 100, height: 200 };
    ProcessingManager.getPreviewForSecond(source, forSecond, maximumSize)
      .then((data) => console.log(data))
  }
  render() {
    return <View />;
  }
}
```

### How to setup Library
[![Setup](https://img.youtube.com/vi/HRjgeT6NQJM/0.jpg)](https://youtu.be/HRjgeT6NQJM)

For Android:

add these lines
```
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

to your AndroidManifest.xml

## Contributing

1. Please follow the eslint style guide.
2. Please commit with `$ npm run commit`

## Roadmap
1.  [ ] Use FFMpeg instead of MP4Parser
2.  [ ] Add ability to add GLSL filters
3.  [x] Android should be able to compress video
4.  [x] More processing options
5.  [ ] Create native trimmer component for Android
6.  [x] Provide Standalone API
7.  [ ] Describe API methods with parameters in README
