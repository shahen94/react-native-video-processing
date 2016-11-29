//
//  RNTrimmerViewBridge.m
//  RNVideoProcessing
//

#import <Foundation/Foundation.h>

#import "RCTBridgeModule.h"
#import "RCTViewManager.h"

@interface RCT_EXTERN_MODULE(RNTrimmerViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(source, NSString)
RCT_EXPORT_VIEW_PROPERTY(width, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(height, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(themeColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(minLength, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(maxLength, NSNumber)

@end
