//
//  ADJActivityHandler.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-01.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "Adjust.h"
#import "ADJResponseData.h"

@interface ADJInternalState : NSObject

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL offline;
@property (nonatomic, assign) BOOL background;
@property (nonatomic, assign) BOOL delayStart;
@property (nonatomic, assign) BOOL eventPreStart;
@property (nonatomic, assign) BOOL updatePackages;
- (id)init;

- (BOOL)isEnabled;
- (BOOL)isDisabled;
- (BOOL)isOffline;
- (BOOL)isOnline;
- (BOOL)isBackground;
- (BOOL)isForeground;
- (BOOL)isDelayStart;
- (BOOL)isToStartNow;
- (BOOL)isEventPreStart;
- (BOOL)isRegularStart;
- (BOOL)isToUpdatePackages;

@end

@protocol ADJActivityHandler <NSObject>

- (id)initWithConfig:(ADJConfig *)adjustConfig
sessionParametersActionsArray:(NSArray*)sessionParametersActionsArray;

- (void)applicationDidBecomeActive;
- (void)applicationWillResignActive;

- (void)trackEvent:(ADJEvent *)event;

- (void)finishedTracking:(ADJResponseData *)responseData;
- (void)launchEventResponseTasks:(ADJEventResponseData *)eventResponseData;
- (void)launchSessionResponseTasks:(ADJSessionResponseData *)sessionResponseData;
- (void)launchAttributionResponseTasks:(ADJAttributionResponseData *)attributionResponseData;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)isEnabled;

- (void)appWillOpenUrl:(NSURL*)url;
- (void)setDeviceToken:(NSData *)deviceToken;

- (void)setAttribution:(ADJAttribution*)attribution;
- (void)setAskingAttribution:(BOOL)askingAttribution;

- (BOOL)updateAttribution:(ADJAttribution *)attribution;
- (void)setIadDate:(NSDate*)iAdImpressionDate withPurchaseDate:(NSDate*)appPurchaseDate;
- (void)setIadDetails:(NSDictionary *)attributionDetails
                error:(NSError *)error
          retriesLeft:(int)retriesLeft;

- (void)setOfflineMode:(BOOL)offline;
- (ADJInternalState*) internalState;
- (void)sendFirstPackages;
- (void)addCustomUserId:(NSString *)customUserId;
- (void)addSessionCallbackParameter:(NSString *)key
                              value:(NSString *)value;
- (void)addSessionPartnerParameter:(NSString *)key
                             value:(NSString *)value;
- (void)removeSessionCallbackParameter:(NSString *)key;
- (void)removeSessionPartnerParameter:(NSString *)key;
- (void)resetCustomUserId;
- (void)resetSessionCallbackParameters;
- (void)resetSessionPartnerParameters;

@end

@interface ADJActivityHandler : NSObject <ADJActivityHandler>

+ (id<ADJActivityHandler>)handlerWithConfig:(ADJConfig *)adjustConfig
             sessionParametersActionsArray:(NSArray*)sessionParametersActionsArray;
- (ADJAttribution*) attribution;

@end
