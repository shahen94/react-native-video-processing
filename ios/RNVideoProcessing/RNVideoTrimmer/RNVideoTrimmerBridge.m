//
//  RNVideoTrimmerBridge.m
//  RNVideoProcessing
//

#import <Foundation/Foundation.h>

#import "RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(RNVideoTrimmer, NSObject)

RCT_EXTERN_METHOD(trim:(NSString *)source startTime:(float *)startTime endTime:(float *)endTime callback:(RCTResponseSenderBlock)callback);
RCT_EXTERN_METHOD(getPreviewImageAtPosition:(NSString *)source atTime:(float *)atTime callback:(RCTResponseSenderBlock)callback);
RCT_EXTERN_METHOD(getAssetInfo:(NSString *)source callback:(RCTResponseSenderBlock)callback);

@end
