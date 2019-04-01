//
//  RCTSwiftBridgeModule.h
//  AwesomeProject
//
//  Created by Slava Semeniuk on 4/1/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#ifndef RCTSwiftBridgeModule_h
#define RCTSwiftBridgeModule_h

#define RCT_EXTERN_SWIFT_MODULE(objc_name, objc_supername) \
RCT_EXTERN_REMAP_SWIFT_MODULE(, objc_name, objc_supername)

#define RCT_EXTERN_REMAP_SWIFT_MODULE(js_name, objc_name, objc_supername) \
objc_name : objc_supername \
@end \
@interface objc_name (RCTExternModule) <RCTBridgeModule> \
@end \
@implementation objc_name (RCTExternModule) \
RCT_EXPORT_SWIFT_MODULE(js_name, objc_name)

#define RCT_EXPORT_SWIFT_MODULE(js_name, objc_name) \
RCT_EXTERN void RCTRegisterModule(Class); \
+ (NSString *)moduleName { return @#js_name; } \
__attribute__((constructor)) static void \
RCT_CONCAT(initialize_, objc_name)() { RCTRegisterModule([objc_name class]); }

#endif /* RCTSwiftBridgeModule_h */
