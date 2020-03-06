//
//  BatchPayloadDispatcherTests.h
//  Batch-Google-Analytics-Dispatcher_Tests
//
//  Created by Elliot Gouy on 31/10/2019.
//  Copyright © 2019 elliot. All rights reserved.
//

#import <Batch/BatchEventDispatcher.h>

@interface BatchPayloadDispatcherTest : NSObject <BatchEventDispatcherPayload>

@property (nullable) NSString *trackingId;
@property (nullable) NSString *deeplink;
@property BOOL isPositiveAction;
@property (nullable) BatchInAppMessage *inAppPayload;
@property (nullable) NSDictionary *pushPayload;

@property (nullable) NSDictionary<NSString *, id> *customPayload;

@end
