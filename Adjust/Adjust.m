//
//  Adjust.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2012-07-23.
//  Copyright (c) 2012-2014 adjust GmbH. All rights reserved.
//

#import "Adjust.h"
#import "ADJActivityHandler.h"
#import "ADJAdjustFactory.h"
#import "ADJLogger.h"
#import "ADJUtil.h"

#if !__has_feature(objc_arc)
#error Adjust requires ARC
// see README for details
#endif

NSString * const ADJEnvironmentSandbox      = @"sandbox";
NSString * const ADJEnvironmentProduction   = @"production";

@interface Adjust()

@property (nonatomic, strong) id<ADJActivityHandler> activityHandler;
@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, strong) NSMutableArray* sessionParametersActionsArray;

@end

#pragma mark -
@implementation Adjust

+ (void)appDidLaunch:(ADJConfig *)adjustConfig {
    [[Adjust getInstance] appDidLaunch:adjustConfig];
}

+ (void)trackEvent:(ADJEvent *)event {
    [[Adjust getInstance] trackEvent:event];
}

+ (void)trackSubsessionStart {
    [[Adjust getInstance] trackSubsessionStart];
}

+ (void)trackSubsessionEnd {
    [[Adjust getInstance] trackSubsessionEnd];
}

+ (void)setEnabled:(BOOL)enabled {
    [[Adjust getInstance] setEnabled:enabled];
}

+ (BOOL)isEnabled {
    return [[Adjust getInstance] isEnabled];
}

+ (void)appWillOpenUrl:(NSURL *)url {
    [[Adjust getInstance] appWillOpenUrl:url];
}

+ (void)setDeviceToken:(NSData *)deviceToken {
    [[Adjust getInstance] setDeviceToken:deviceToken];
}

+ (void)setOfflineMode:(BOOL)enabled {
    [[Adjust getInstance] setOfflineMode:enabled];
}

+ (NSString*)idfa {
    return [[Adjust getInstance] idfa];
}

+ (NSURL*)convertUniversalLink:(NSURL *)url scheme:(NSString *)scheme {
    return [[Adjust getInstance] convertUniversalLink:url scheme:scheme];
}

+ (void)sendFirstPackages {
    [[Adjust getInstance] sendFirstPackages];
}

+ (void)addCustomUserId:(NSString *)customUserId {
    [[Adjust getInstance] addCustomUserId:customUserId];
}

+ (void)addSessionCallbackParameter:(NSString *)key
                              value:(NSString *)value {
    [[Adjust getInstance] addSessionCallbackParameter:key value:value];

}

+ (void)addSessionPartnerParameter:(NSString *)key
                             value:(NSString *)value {
    [[Adjust getInstance] addSessionPartnerParameter:key value:value];
}


+ (void)removeSessionCallbackParameter:(NSString *)key {
    [[Adjust getInstance] removeSessionCallbackParameter:key];
}

+ (void)removeSessionPartnerParameter:(NSString *)key {
    [[Adjust getInstance] removeSessionPartnerParameter:key];
}

+ (void)resetCustomUserId {
    [[Adjust getInstance] resetCustomUserId];
}

+ (void)resetSessionCallbackParameters {
    [[Adjust getInstance] resetSessionCallbackParameters];
}

+ (void)resetSessionPartnerParameters {
    [[Adjust getInstance] resetSessionPartnerParameters];
}

+ (id)getInstance {
    static Adjust *defaultInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultInstance = [[self alloc] init];
    });

    return defaultInstance;
}

- (id) init {
    self = [super init];
    if (self == nil) return nil;

    self.activityHandler = nil;
    self.logger = [ADJAdjustFactory logger];

    return self;
}

- (void)appDidLaunch:(ADJConfig *)adjustConfig {
    if (self.activityHandler != nil) {
        [self.logger error:@"Adjust already initialized"];
        return;
    }

    self.activityHandler = [ADJAdjustFactory activityHandlerWithConfig:adjustConfig
                                        sessionParametersActionsArray:self.sessionParametersActionsArray];
}

- (void)trackEvent:(ADJEvent *)event {
    if (![self checkActivityHandler]) return;
    [self.activityHandler trackEvent:event];
}

- (void)trackSubsessionStart {
    if (![self checkActivityHandler]) return;
    [self.activityHandler applicationDidBecomeActive];
}

- (void)trackSubsessionEnd {
    if (![self checkActivityHandler]) return;
    [self.activityHandler applicationWillResignActive];
}

- (void)setEnabled:(BOOL)enabled {
    if (![self checkActivityHandler]) return;
    [self.activityHandler setEnabled:enabled];
}

- (BOOL)isEnabled {
    if (![self checkActivityHandler]) return NO;
    return [self.activityHandler isEnabled];
}

- (void)appWillOpenUrl:(NSURL *)url {
    if (![self checkActivityHandler]) return;
    [self.activityHandler  appWillOpenUrl:url];
}

- (void)setDeviceToken:(NSData *)deviceToken {
    if (![self checkActivityHandler]) return;
    [self.activityHandler setDeviceToken:deviceToken];
}

- (void)setOfflineMode:(BOOL)enabled {
    if (![self checkActivityHandler]) return;
    [self.activityHandler setOfflineMode:enabled];
}

- (NSString*)idfa {
    return [ADJUtil idfa];
}

- (NSURL*)convertUniversalLink:(NSURL *)url scheme:(NSString *)scheme {
    return [ADJUtil convertUniversalLink:url scheme:scheme];
}

- (void)sendFirstPackages {
    if (![self checkActivityHandler]) return;
    [self.activityHandler sendFirstPackages];
}

- (void)addCustomUserId:(NSString *)customUserId {
    if (self.activityHandler != nil) {
        [self.activityHandler addCustomUserId:customUserId];
        return;
    }

    if (self.sessionParametersActionsArray == nil) {
        self.sessionParametersActionsArray = [[NSMutableArray alloc] init];
    }

    NSArray * action = @[@"add", @"customUserId", customUserId];
    [self.sessionParametersActionsArray addObject:action];
}

- (void)addSessionCallbackParameter:(NSString *)key
                              value:(NSString *)value {
    if (self.activityHandler != nil) {
        [self.activityHandler addSessionCallbackParameter:key value:value];
        return;
    }

    if (self.sessionParametersActionsArray == nil) {
        self.sessionParametersActionsArray = [[NSMutableArray alloc] init];
    }

    NSArray * action = @[@"add", @"callback", key, value];
    [self.sessionParametersActionsArray addObject:action];
}

- (void)addSessionPartnerParameter:(NSString *)key
                             value:(NSString *)value {
    if (self.activityHandler != nil) {
        [self.activityHandler addSessionPartnerParameter:key value:value];
        return;
    }

    if (self.sessionParametersActionsArray == nil) {
        self.sessionParametersActionsArray = [[NSMutableArray alloc] init];
    }

    NSArray * action = @[@"add", @"partner", key, value];
    [self.sessionParametersActionsArray addObject:action];
}

- (void)removeSessionCallbackParameter:(NSString *)key {
    if (self.activityHandler != nil) {
        [self.activityHandler removeSessionCallbackParameter:key];
        return;
    }

    if (self.sessionParametersActionsArray == nil) {
        self.sessionParametersActionsArray = [[NSMutableArray alloc] init];
    }

    NSArray * action = @[@"remove", @"callback", key];
    [self.sessionParametersActionsArray addObject:action];
}

- (void)removeSessionPartnerParameter:(NSString *)key {
    if (self.activityHandler != nil) {
        [self.activityHandler removeSessionPartnerParameter:key];
        return;
    }

    if (self.sessionParametersActionsArray == nil) {
        self.sessionParametersActionsArray = [[NSMutableArray alloc] init];
    }

    NSArray * action = @[@"remove", @"partner", key];
    [self.sessionParametersActionsArray addObject:action];
}

- (void)resetCustomUserId {
    if (self.activityHandler != nil) {
        [self.activityHandler resetCustomUserId];
        return;
    }

    if (self.sessionParametersActionsArray == nil) {
        self.sessionParametersActionsArray = [[NSMutableArray alloc] init];
    }

    NSArray * action = @[@"reset", @"customUserId"];
    [self.sessionParametersActionsArray addObject:action];
}

- (void)resetSessionCallbackParameters {
    if (self.activityHandler != nil) {
        [self.activityHandler resetSessionCallbackParameters];
        return;
    }

    if (self.sessionParametersActionsArray == nil) {
        self.sessionParametersActionsArray = [[NSMutableArray alloc] init];
    }

    NSArray * action = @[@"reset", @"callback"];
    [self.sessionParametersActionsArray addObject:action];
}

- (void)resetSessionPartnerParameters {
    if (self.activityHandler != nil) {
        [self.activityHandler resetSessionPartnerParameters];
        return;
    }

    if (self.sessionParametersActionsArray == nil) {
        self.sessionParametersActionsArray = [[NSMutableArray alloc] init];
    }

    NSArray * action = @[@"reset", @"partner"];
    [self.sessionParametersActionsArray addObject:action];
}


#pragma mark - private

- (BOOL) checkActivityHandler {
    if (self.activityHandler == nil) {
        [self.logger error:@"Please initialize Adjust by calling 'appDidLaunch' before"];
        return NO;
    } else {
        return YES;
    }
}

@end
