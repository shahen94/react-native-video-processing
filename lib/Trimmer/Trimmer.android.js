import React, { PropTypes, PureComponent } from 'react';
import {
  View,
  Image,
  NativeModules,
  StyleSheet,
  Dimensions,
  PanResponder,
  Animated
} from 'react-native';

const { RNTrimmerManager: TrimmerManager } = NativeModules;
const { width, height } = Dimensions.get('window');

const styles = StyleSheet.create({

  container: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center'
  },
  imageItem: {
    flex: 1,
    width: 50,
    height: 50,
    resizeMode: 'cover'
  },
  corners: {
    position: 'absolute',
    height: 50,
    flex: 1,
    justifyContent: 'center',
  },
  rightCorner: {
    right: 0
  },
  leftCorner: {
    left: 0
  }
});
export class Trimmer extends PureComponent {
  static propTypes = {
    source: PropTypes.string.isRequired,
    onChange: PropTypes.func
  }
  static defaultProps: {
    onChange: () => null
  }

  constructor(props) {
    super(props);
    this.state = {
      images: [],
      duration: -1,
      leftCorner: new Animated.Value(0),
      rightCorner: new Animated.Value(0)
    };

    this.leftResponder = null;
    this.rigthResponder = null;

    this._handleRightCornerMove = this._handleRightCornerMove.bind(this);
    this._handleLeftCornerMove = this._handleLeftCornerMove.bind(this);
    this._retriveInfo = this._retriveInfo.bind(this);
    this._retrivePreviewImages = this._retrivePreviewImages.bind(this);
    this._handleRightCornerRelease = this._handleRightCornerRelease.bind(this);
    this._handleLeftCornerRelease = this._handleLeftCornerRelease.bind(this);
  }

  componentWillMount() {
    // @TODO: Cleanup on unmount
    this.state.leftCorner.addListener(({ value }) => this._leftCornerPos = value);
    this.state.rightCorner.addListener(({ value }) => this._rightCornerPos = value);

    this.leftResponder = PanResponder.create({
      onMoveShouldSetPanResponder: (e, gestureState) => Math.abs(gestureState.dx) > 0,
      onMoveShouldSetPanResponderCapture: (e, gestureState) => Math.abs(gestureState.dx) > 0,
      onPanResponderMove: this._handleLeftCornerMove,
      onPanResponderRelease: this._handleLeftCornerRelease
    });

    this.rightResponder = PanResponder.create({
      onMoveShouldSetPanResponder: (e, gestureState) => Math.abs(gestureState.dx) > 0,
      onMoveShouldSetPanResponderCapture: (e, gestureState) => Math.abs(gestureState.dx) > 0,
      onPanResponderMove: this._handleRightCornerMove,
      onPanResponderRelease: this._handleRightCornerRelease
    });
    const { source = '' } = this.props;
    if (!source.trim()) {
      throw new Error('source should be valid string');
    }
    if (!TrimmerManager) {
      throw new Error('RNTrimmerManager: Native Module installed not correctly');
    }
    this._retrivePreviewImages();
    this._retriveInfo();
  }

  _handleLeftCornerRelease() {
    this.state.leftCorner.setOffset(this._leftCornerPos);
    this.state.leftCorner.setValue(0);

    // TODO: call onChange prop and set startTime value
  }

  _handleRightCornerRelease() {
    this.state.rightCorner.setOffset(this._rightCornerPos);
    this.state.rightCorner.setValue(0);

    // TODO: call onChange prop and set endTime value
  }

  _handleRightCornerMove(e, gestureState) {
    Animated.event([
      null,
       { dx: this.state.rightCorner }
     ])(e, gestureState);
  }

  _handleLeftCornerMove(e, gestureState) {
    Animated.event([
      null,
       { dx: this.state.leftCorner }
     ])(e, gestureState);
  }

  _retriveInfo() {
    TrimmerManager
      .getVideoInfo(this.props.source)
      .then((info) => this.setState(info));
  }

  _retrivePreviewImages() {
    TrimmerManager
      .getPreviewImages(this.props.source)
      .then(({ images }) => {
        this.setState({ images });
      })
      .catch((e) => console.error(e));
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.source !== this.props.source) {
      this._retrivePreviewImages();
      this._retriveInfo();
    }
  }

  renderLeftSection() {
    const { leftCorner } = this.state;
    return (
      <Animated.View
        style={[styles.container, styles.leftCorner, {
          transform: [{
            translateX: leftCorner
          }]
        }]}
        {...this.leftResponder.panHandlers}
      >
        <View style={{ backgroundColor: 'blue', width: 20, height: 50 }}>
        </View>
      </Animated.View>
    );
  }

  renderRightSection() {
    const { rightCorner } = this.state;
    return (
      <Animated.View
        style={[styles.container, { backgroundColor: 'red', width: 20, height: 50 }, styles.rightCorner, {
          transform: [{
            translateX: rightCorner
          }]
        }]}
        {...this.rightResponder.panHandlers}
      >

      </Animated.View>
    )
  }

  render() {
    const { images } = this.state;
    return (
      <View style={styles.container}>
        {images.map((uri) => (
          <Image
            key={`preview-source-${uri}`}
            source={{ uri }}
            style={styles.imageItem}
          />
        ))}
        <View style={styles.corners}>
          {this.renderLeftSection()}
          {this.renderRightSection()}
        </View>
      </View>
    );
  }
}
