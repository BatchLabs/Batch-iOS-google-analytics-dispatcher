//
//  BatchGoogleAnalyticsDispatcher.m
//  Batch-Google-Analytics-Dispatcher_Tests
//
//  Created by Elliot Gouy on 31/10/2019.
//  Copyright © 2019 elliot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <OCMock.h>
#import <GoogleAnalytics/GAI.h>

#import "BatchGoogleAnalyticsDispatcher.h"
#import "BatchPayloadDispatcherTests.h"

@interface BatchGoogleAnalyticsDispatcherTests : XCTestCase

@property (nonatomic) id googleAnalyticsMock;
@property (nonatomic) id trackerMock;

@property (nonatomic) BatchGoogleAnalyticsDispatcher *dispatcher;

@end


@implementation BatchGoogleAnalyticsDispatcherTests

- (void)setUp
{
    [super setUp];

    //GAI *gai = [GAI sharedInstance];
    //id<GAITracker> tracker = [gai trackerWithTrackingId:gaTrackingId];
    //[tracker send:[builder build]];
    
    _googleAnalyticsMock = OCMClassMock([GAI class]);
    _trackerMock = OCMProtocolMock(@protocol(GAITracker));

    OCMStub(ClassMethod([_googleAnalyticsMock sharedInstance])).andReturn(_googleAnalyticsMock);
    OCMStub([_googleAnalyticsMock trackerWithTrackingId:[OCMArg any]]).andReturn(_trackerMock);
    
    [BatchGoogleAnalyticsDispatcher trackerWithTrackingId:@"test"];
    _dispatcher = [BatchGoogleAnalyticsDispatcher instance];
}

- (void)tearDown
{
    [super tearDown];
    
    [_googleAnalyticsMock stopMocking];
    _googleAnalyticsMock = nil;
    
    [_trackerMock stopMocking];
    _trackerMock = nil;
}

- (void)testPushNoData
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen andPayload:testPayload];
    
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"&ec": @"push",
        @"&t": @"event",
        @"&cm": @"push",
        @"&ea": @"batch_notification_open",
        @"&el": @"batch",
        @"&cs": @"batch",
    };
    OCMVerify([_trackerMock send:expectedParameters]);
}

- (void)testNotificationDeeplinkQueryVars
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com?utm_source=batchsdk&utm_medium=push-batch&utm_campaign=yoloswag&utm_content=button1";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen andPayload:testPayload];
    
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"&ec": @"push",
        @"&t": @"event",
        @"&cm": @"push-batch",
        @"&ea": @"batch_notification_open",
        @"&el": @"batch",
        @"&cs": @"batchsdk",
        @"&cn": @"yoloswag",
        @"&cc": @"button1"
    };
    OCMVerify([_trackerMock send:expectedParameters]);
}

- (void)testNotificationDeeplinkQueryVarsEncode
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com?utm_source=%5Bbatchsdk%5D&utm_medium=push-batch&utm_campaign=yoloswag&utm_content=button1";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen andPayload:testPayload];
    
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"&ec": @"push",
        @"&t": @"event",
        @"&cm": @"push-batch",
        @"&ea": @"batch_notification_open",
        @"&el": @"batch",
        @"&cs": @"[batchsdk]",
        @"&cn": @"yoloswag",
        @"&cc": @"button1"
    };
    OCMVerify([_trackerMock send:expectedParameters]);
}

- (void)testNotificationDeeplinkFragmentVars
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com#utm_source=batch-sdk&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen andPayload:testPayload];
    
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"&ec": @"push",
        @"&t": @"event",
        @"&cm": @"pushbatch01",
        @"&ea": @"batch_notification_open",
        @"&el": @"batch",
        @"&cs": @"batch-sdk",
        @"&cn": @"154879548754",
        @"&cc": @"notif001"
    };
    OCMVerify([_trackerMock send:expectedParameters]);
}

- (void)testNotificationDeeplinkNonTrimmed
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"    \n     https://batch.com#utm_source=batch-sdk&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001     \n    ";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen andPayload:testPayload];
    
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"&ec": @"push",
        @"&t": @"event",
        @"&cm": @"pushbatch01",
        @"&ea": @"batch_notification_open",
        @"&el": @"batch",
        @"&cs": @"batch-sdk",
        @"&cn": @"154879548754",
        @"&cc": @"notif001"
    };
    OCMVerify([_trackerMock send:expectedParameters]);
}

- (void)testNotificationDeeplinkFragmentVarsEncode
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test#utm_source=%5Bbatch-sdk%5D&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen andPayload:testPayload];
    
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"&ec": @"push",
        @"&t": @"event",
        @"&cm": @"pushbatch01",
        @"&ea": @"batch_notification_open",
        @"&el": @"batch",
        @"&cs": @"[batch-sdk]",
        @"&cn": @"154879548754",
        @"&cc": @"notif001"
    };
    OCMVerify([_trackerMock send:expectedParameters]);
}

- (void)testNotificationCustomPayload
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com#utm_source=batch-sdk&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001";
    testPayload.customPayload = @{
        @"utm_medium": @"654987",
        @"utm_source": @"jesuisuntest",
        @"utm_campaign": @"heinhein",
        @"utm_content": @"allo118218",
    };
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen andPayload:testPayload];
    
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"&ec": @"push",
        @"&t": @"event",
        @"&cm": @"654987",
        @"&ea": @"batch_notification_open",
        @"&el": @"batch",
        @"&cs": @"jesuisuntest",
        @"&cn": @"heinhein",
        @"&cc": @"notif001"
    };
    OCMVerify([_trackerMock send:expectedParameters]);
}

- (void)testNotificationDeeplinkPriority
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com?utm_source=batchsdk&utm_campaign=yoloswag#utm_source=batch-sdk&utm_medium=pushbatch01&utm_campaign=154879548754&utm_content=notif001";
    testPayload.customPayload = @{
        @"utm_medium": @"654987",
    };
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeNotificationOpen andPayload:testPayload];
    
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"&ec": @"push",
        @"&t": @"event",
        @"&ea": @"batch_notification_open",
        @"&el": @"batch",
        @"&cm": @"654987",
        @"&cs": @"batchsdk",
        @"&cn": @"yoloswag",
        @"&cc": @"notif001",
    };
    OCMVerify([_trackerMock send:expectedParameters]);
}

- (void)testInAppNoData
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeInAppShow andPayload:testPayload];
    
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"&ec": @"in-app",
        @"&t": @"event",
        @"&cm": @"in-app",
        @"&ea": @"batch_in_app_show",
        @"&el": @"batch",
        @"&cs": @"batch",
    };
    OCMVerify([_trackerMock send:expectedParameters]);
}

- (void)testInAppTrackingID
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.trackingId = @"jesuisuntrackingid";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeInAppShow andPayload:testPayload];
    
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"&ec": @"in-app",
        @"&t": @"event",
        @"&cm": @"in-app",
        @"&ea": @"batch_in_app_show",
        @"&el": @"batch",
        @"&cs": @"batch",
        @"&cn": @"jesuisuntrackingid",
        @"batch_tracking_id": @"jesuisuntrackingid"
    };
    OCMVerify([_trackerMock send:expectedParameters]);
}

- (void)testInAppDeeplinkContentQueryVars
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test-ios?utm_content=yoloswag";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeInAppClick andPayload:testPayload];
    
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"&ec": @"in-app",
        @"&t": @"event",
        @"&cm": @"in-app",
        @"&ea": @"batch_in_app_click",
        @"&el": @"batch",
        @"&cs": @"batch",
        @"&cc": @"yoloswag"
    };
    OCMVerify([_trackerMock send:expectedParameters]);
}

- (void)testInAppDeeplinkContentQueryVarsUppercase
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test-ios?UtM_coNTEnt=yoloswag";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeInAppClick andPayload:testPayload];
    
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"&ec": @"in-app",
        @"&t": @"event",
        @"&cm": @"in-app",
        @"&ea": @"batch_in_app_click",
        @"&el": @"batch",
        @"&cs": @"batch",
        @"&cc": @"yoloswag"
    };
    OCMVerify([_trackerMock send:expectedParameters]);
}


- (void)testInAppDeeplinkFragmentQueryVars
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test-ios#utm_content=yoloswag2";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeInAppClick andPayload:testPayload];
    
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"&ec": @"in-app",
        @"&t": @"event",
        @"&cm": @"in-app",
        @"&ea": @"batch_in_app_click",
        @"&el": @"batch",
        @"&cs": @"batch",
        @"&cc": @"yoloswag2"
    };
    OCMVerify([_trackerMock send:expectedParameters]);
}

- (void)testInAppDeeplinkFragmentQueryVarsUppercase
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test-ios#uTm_CoNtEnT=yoloswag2";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeInAppClick andPayload:testPayload];
    
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"&ec": @"in-app",
        @"&t": @"event",
        @"&cm": @"in-app",
        @"&ea": @"batch_in_app_click",
        @"&el": @"batch",
        @"&cs": @"batch",
        @"&cc": @"yoloswag2"
    };
    OCMVerify([_trackerMock send:expectedParameters]);
}

- (void)testInAppDeeplinkContentPriority
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com/test-ios?utm_content=testprio#utm_content=yoloswag2";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeInAppClose andPayload:testPayload];
    
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"&ec": @"in-app",
        @"&t": @"event",
        @"&cm": @"in-app",
        @"&ea": @"batch_in_app_close",
        @"&el": @"batch",
        @"&cs": @"batch",
        @"&cc": @"testprio"
    };
    OCMVerify([_trackerMock send:expectedParameters]);
}

- (void)testInAppDeeplinkContentNoId
{
    BatchPayloadDispatcherTest *testPayload = [[BatchPayloadDispatcherTest alloc] init];
    testPayload.deeplink = @"https://batch.com?utm_content=jesuisuncontent";
    
    [self.dispatcher dispatchEventWithType:BatchEventDispatcherTypeInAppAutoClose andPayload:testPayload];
    
    NSDictionary<NSString *, id> *expectedParameters = @{
        @"&ec": @"in-app",
        @"&t": @"event",
        @"&cm": @"in-app",
        @"&ea": @"batch_in_app_auto_close",
        @"&el": @"batch",
        @"&cs": @"batch",
        @"&cc": @"jesuisuncontent"
    };
    OCMVerify([_trackerMock send:expectedParameters]);
}

@end
