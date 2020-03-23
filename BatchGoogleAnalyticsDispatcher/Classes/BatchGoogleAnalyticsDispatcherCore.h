#import <Batch/BatchEventDispatcher.h>

@interface BatchGoogleAnalyticsDispatcher : NSObject <BatchEventDispatcherDelegate>

+ (nonnull instancetype)instance;
+ (void)trackerWithTrackingId:(nonnull NSString *)trackingId;

@end
