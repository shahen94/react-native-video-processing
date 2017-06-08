//
//  RNTrimmerViewBridge.m
//  RNVideoProcessing
//

#import <Foundation/Foundation.h>

#import "React/RCTBridgeModule.h"
#import "React/RCTViewManager.h"

@interface RCT_EXTERN_MODULE(RNTrimmerViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(source, NSString)
RCT_EXPORT_VIEW_PROPERTY(width, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(height, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(themeColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onTrackerMove, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(minLength, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(maxLength, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(currentTime, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(trackerColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(thumbWidth, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(showTrackerHandle, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(trackerHandleColor, NSString)

@end
