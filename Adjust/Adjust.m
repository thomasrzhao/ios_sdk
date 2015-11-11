//
//  Adjust.m
//  adjust GmbH
//
//  Created by Christian Wellenbrock on 23/07/2012.
//  Copyright (c) 2012-2015 adjust GmbH. All rights reserved.
//

#import "Adjust.h"
#import "ADJLogger.h"
#import "ADJAdjustFactory.h"
#import "ADJActivityHandler.h"

#if !__has_feature(objc_arc)
#error Adjust requires ARC
// See README for details.
#endif

NSString * const ADJEnvironmentSandbox      = @"sandbox";
NSString * const ADJEnvironmentProduction   = @"production";

@interface Adjust()

@property (nonatomic, retain) id<ADJLogger> logger;
@property (nonatomic, retain) id<ADJActivityHandler> activityHandler;

@end

@implementation Adjust

#pragma mark - Object lifecycle

- (id)init {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    self.activityHandler = nil;
    self.logger = [ADJAdjustFactory logger];

    return self;
}

#pragma mark - Private methods

- (BOOL)checkActivityHandler {
    if (self.activityHandler == nil) {
        [self.logger error:@"Please initialize Adjust by calling 'appDidLaunch' before"];
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Public static methods

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

+ (id)getInstance {
    static Adjust *defaultInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        defaultInstance = [[self alloc] init];
    });

    return defaultInstance;
}

#pragma mark - Public instance methods

- (void)appDidLaunch:(ADJConfig *)adjustConfig {
    if (self.activityHandler != nil) {
        [self.logger error:@"Adjust already initialized"];
        return;
    }

    self.activityHandler = [ADJAdjustFactory activityHandlerWithConfig:adjustConfig];
}

- (void)trackEvent:(ADJEvent *)event {
    if (![self checkActivityHandler]) {
        return;
    }

    [self.activityHandler trackEvent:event];
}

- (void)trackSubsessionStart {
    if (![self checkActivityHandler]) {
        return;
    }

    [self.activityHandler trackSubsessionStart];
}

- (void)trackSubsessionEnd {
    if (![self checkActivityHandler]) {
        return;
    }

    [self.activityHandler trackSubsessionEnd];
}

- (void)setEnabled:(BOOL)enabled {
    if (![self checkActivityHandler]) {
        return;
    }

    [self.activityHandler setEnabled:enabled];
}

- (BOOL)isEnabled {
    if (![self checkActivityHandler]) {
        return NO;
    }

    return [self.activityHandler isEnabled];
}

- (void)appWillOpenUrl:(NSURL *)url {
    if (![self checkActivityHandler]) {
        return;
    }

    [self.activityHandler appWillOpenUrl:url];
}

- (void)setDeviceToken:(NSData *)deviceToken {
    if (![self checkActivityHandler]) {
        return;
    }

    [self.activityHandler setDeviceToken:deviceToken];
}

- (void)setOfflineMode:(BOOL)enabled {
    if (![self checkActivityHandler]) {
        return;
    }

    [self.activityHandler setOfflineMode:enabled];
}

@end
