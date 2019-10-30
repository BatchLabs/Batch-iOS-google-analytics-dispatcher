#import <Foundation/Foundation.h>
NSString* const BatchGoogleAnalyticsTrackingId = @"batch_tracking_id";

// Begin BGADDictionaryBuilder.h
// We declare the interface here because GoogleAnalytics is not a modular framework and we won't be able to compile the project
// This should be copied in the .m it needs to be used in
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

@implementation BGADDictionaryBuilder

+ (nonnull instancetype)createWithAction:(nonnull NSString*)action
{
    return [[self alloc] initWithAction:action];
}

- (instancetype)initWithAction:(NSString*)action
{
    self = [super init];
    if (self) {
        [self set:kGAIEvent forKey:kGAIHitType];
        [self set:@"batch" forKey:kGAIEventLabel];
        [self set:action forKey:kGAIEventAction];
    }
    return self;
}

- (nonnull instancetype)setCampaignName:(nullable NSString*)name
{
    if (name != nil) {
        [self set:name forKey:kGAICampaignName];
    }
    return self;
}

- (nonnull instancetype)setCampaignSource:(nullable NSString*)source
{
    if (source != nil) {
        [self set:source forKey:kGAICampaignSource];
    }
    return self;
}

- (nonnull instancetype)setCampaignMedium:(nullable NSString*)medium
{
    if (medium != nil) {
        [self set:medium forKey:kGAICampaignMedium];
    }
    return self;
}

- (nonnull instancetype)setCampaignContent:(nullable NSString*)content
{
    if (content != nil) {
        [self set:content forKey:kGAICampaignContent];
    }
    return self;
}

- (nonnull instancetype)setCategory:(nullable NSString*)category
{
    if (category != nil) {
        [self set:category forKey:kGAIEventCategory];
    }
    return self;
}

- (nonnull instancetype)setTrackingId:(nullable NSString*)trackingId
{
    if (trackingId != nil) {
        [self set:trackingId forKey:BatchGoogleAnalyticsTrackingId];
    }
    return self;
}

@end
