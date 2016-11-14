//
//  RNVideoProcessingBridge.m
//  RNVideoProcessing
//

#import <Foundation/Foundation.h>

#import "RCTBridgeModule.h"
#import "RCTViewManager.h"

@interface RCT_EXTERN_MODULE(RNVideoProcessingManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(source, NSString)
RCT_EXPORT_VIEW_PROPERTY(currentTime, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(startTime, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(endTime, NSNumber)


@end
