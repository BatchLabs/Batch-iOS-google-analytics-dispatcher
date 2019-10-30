#import <Foundation/Foundation.h>
#import <GoogleAnalytics/GAI.h>

#import "BatchGoogleAnalyticsDispatcher.h"

// Begin BGADDictionaryBuilder.h
// See BGADDictionaryBuilder.m for more info
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import <GoogleAnalytics/GAIFields.h>

@interface BGADDictionaryBuilder : GAIDictionaryBuilder

+ (nonnull instancetype)createWithAction:(nonnull NSString*)action;

- (nonnull instancetype)setCampaignName:(nullable NSString*)name;
- (nonnull instancetype)setCampaignSource:(nullable NSString*)source;
- (nonnull instancetype)setCampaignMedium:(nullable NSString*)medium;
- (nonnull instancetype)setCampaignContent:(nullable NSString*)content;
- (nonnull instancetype)setCategory:(nullable NSString*)category;
- (nonnull instancetype)setTrackingId:(nullable NSString*)trackingId;

@end
// end BGADDictionaryBuilder.h

NSString* const BatchGoogleAnalyticsUtmCampaign = @"utm_campaign";
NSString* const BatchGoogleAnalyticsUtmSource = @"utm_source";
NSString* const BatchGoogleAnalyticsUtmMedium = @"utm_medium";
NSString* const BatchGoogleAnalyticsUtmContent = @"utm_content";

@implementation BatchGoogleAnalyticsDispatcher {
    NSString *gaTrackingId;
}

+ (void)load {
    [BatchEventDispatcher addDispatcher:[self instance]];
}

+ (instancetype)instance
{
    static BatchGoogleAnalyticsDispatcher *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BatchGoogleAnalyticsDispatcher alloc] init];
    });
    
    return sharedInstance;
}

+ (void)trackerWithTrackingId:(NSString *)trackingId
{
    BatchGoogleAnalyticsDispatcher *instance = [self instance];
    if (instance != nil) {
        [instance trackerWithTrackingId:trackingId];
    }
}

- (void)trackerWithTrackingId:(nonnull NSString *)trackingId
{
    gaTrackingId = trackingId;
}

- (void)dispatchEventWithType:(BatchEventDispatcherType)type payload:(nonnull id<BatchEventDispatcherPayload>)payload {
    if (gaTrackingId == nil) {
        return;
    }
    
    BGADDictionaryBuilder *builder = [BGADDictionaryBuilder createWithAction:[self stringFromEventType:type]];
    if ([BatchEventDispatcher isNotificationEvent:type]) {
        [self notificationParamsFromBuilder:builder andPayload:payload];
    } else if ([BatchEventDispatcher isMessagingEvent:type]) {
        [self inAppParamsFromBuilder:builder andPayload:payload];
    }
    
    GAI *gai = [GAI sharedInstance];
    id<GAITracker> tracker = [gai trackerWithTrackingId:gaTrackingId];
    NSDictionary *tmp = [builder build];
    for(NSString *key in [tmp allKeys]) {
        NSLog(@"%@ : %@", key, [tmp objectForKey:key]);
    }
    [tracker send:tmp];
}

-(void)inAppParamsFromBuilder:(nonnull BGADDictionaryBuilder*)builder
                   andPayload:(nonnull id<BatchEventDispatcherPayload>)payload
{
    [builder setCategory:@"in-app"];
    [builder setCampaignSource:@"batch"];
    [builder setCampaignMedium:@"in-app"];
    [builder setCampaignName:payload.trackingId];
    [builder setTrackingId:payload.trackingId];
    
    NSString *deeplink = payload.deeplink;
    if (deeplink != nil) {
        deeplink = [deeplink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSURL *url = [NSURL URLWithString:deeplink];
        if (url != nil) {
            NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:false];
            if (components != nil) {
                
                // Override with values from URL fragment parameters
                if (components.fragment != nil) {
                    NSDictionary *fragments = [self dictFragment:components.fragment];
                    [builder setCampaignContent:[fragments objectForKey:BatchGoogleAnalyticsUtmContent]];
                }
                
                // Override with values from URL query parameters
                [builder setCampaignContent:[self searchInQueryParam:components forKey:BatchGoogleAnalyticsUtmContent]];
            }
        }
    }
    
    // Override with values from custom payload
    [builder setCampaignName:(NSString*)[payload customValueForKey:BatchGoogleAnalyticsUtmCampaign]];
    [builder setCampaignMedium:(NSString*)[payload customValueForKey:BatchGoogleAnalyticsUtmMedium]];
    [builder setCampaignSource:(NSString*)[payload customValueForKey:BatchGoogleAnalyticsUtmSource]];
}

-(void)notificationParamsFromBuilder:(nonnull BGADDictionaryBuilder*)builder
                          andPayload:(nonnull id<BatchEventDispatcherPayload>)payload
{
    [builder setCategory:@"push"];
    [builder setCampaignSource:@"batch"];
    [builder setCampaignMedium:@"push"];
    
    NSString *deeplink = payload.deeplink;
    if (deeplink != nil) {
        deeplink = [deeplink stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSURL *url = [NSURL URLWithString:deeplink];
        if (url != nil) {
            NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:false];
            if (components != nil) {
                
                // Override with values from URL fragment parameters
                if (components.fragment != nil) {
                    NSDictionary *fragments = [self dictFragment:components.fragment];
                    [builder setCampaignName:[fragments objectForKey:BatchGoogleAnalyticsUtmCampaign]];
                    [builder setCampaignMedium:[fragments objectForKey:BatchGoogleAnalyticsUtmMedium]];
                    [builder setCampaignSource:[fragments objectForKey:BatchGoogleAnalyticsUtmSource]];
                    [builder setCampaignContent:[fragments objectForKey:BatchGoogleAnalyticsUtmContent]];
                }
                
                // Override with values from URL query parameters
                [builder setCampaignName:[self searchInQueryParam:components forKey:BatchGoogleAnalyticsUtmCampaign]];
                [builder setCampaignMedium:[self searchInQueryParam:components forKey:BatchGoogleAnalyticsUtmMedium]];
                [builder setCampaignSource:[self searchInQueryParam:components forKey:BatchGoogleAnalyticsUtmSource]];
                [builder setCampaignContent:[self searchInQueryParam:components forKey:BatchGoogleAnalyticsUtmContent]];
            }
        }
    }
    
    // Override with values from custom payload
    [builder setCampaignName:(NSString*)[payload customValueForKey:BatchGoogleAnalyticsUtmCampaign]];
    [builder setCampaignMedium:(NSString*)[payload customValueForKey:BatchGoogleAnalyticsUtmMedium]];
    [builder setCampaignSource:(NSString*)[payload customValueForKey:BatchGoogleAnalyticsUtmSource]];
}

-(NSDictionary*)dictFragment:(nonnull NSString*)fragment
{
    NSMutableDictionary<NSString *, id> *fragments = [NSMutableDictionary dictionary];
    NSArray *fragmentComponents = [fragment componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in fragmentComponents) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[[pairComponents firstObject] stringByRemovingPercentEncoding] lowercaseString];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];

        [fragments setObject:value forKey:key];
    }
    return fragments;
}

-(nullable NSString*)searchInQueryParam:(nonnull NSURLComponents*)components
                                 forKey:(nonnull NSString*)fromKey
{
    for (NSURLQueryItem *item in components.queryItems) {
        if ([fromKey caseInsensitiveCompare:item.name] == NSOrderedSame) {
            return item.value;
        }
    }
    return nil;
}

- (nonnull NSString*)stringFromEventType:(BatchEventDispatcherType)eventType
{
    switch (eventType) {
        case BatchEventDispatcherTypeNotificationOpen:
            return @"batch_notification_open";
        case BatchEventDispatcherTypeMessagingShow:
            return @"batch_in_app_show";
        case BatchEventDispatcherTypeMessagingClose:
            return @"batch_in_app_close";
        case BatchEventDispatcherTypeMessagingAutoClose:
            return @"batch_in_app_auto_close";
        case BatchEventDispatcherTypeMessagingClick:
            return @"batch_in_app_click";
        default:
            return @"batch_unknown";
    }
}

@end
