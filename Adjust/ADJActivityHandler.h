//
//  ADJActivityHandler.h
//  adjust
//
//  Created by Christian Wellenbrock on 01/07/2013.
//  Copyright (c) 2013-2015 adjust GmbH. All rights reserved.
//

#import "Adjust.h"
#import "ADJAttribution.h"

@protocol ADJActivityHandler <NSObject>

- (id)initWithConfig:(ADJConfig *)adjustConfig;

- (BOOL)isEnabled;
- (ADJAttribution *)attribution;

- (void)trackSubsessionEnd;
- (void)trackSubsessionStart;

- (void)setEnabled:(BOOL)enabled;
- (void)appWillOpenUrl:(NSURL *)url;
- (void)trackEvent:(ADJEvent *)event;
- (void)setOfflineMode:(BOOL)offline;
- (void)setDeviceToken:(NSData *)deviceToken;

- (void)setAttribution:(ADJAttribution *)attribution;
- (void)setAskingAttribution:(BOOL)askingAttribution;

- (void)launchAttributionDelegate;
- (void)finishedTracking:(NSDictionary *)jsonDict;
- (BOOL)updateAttribution:(ADJAttribution *)attribution;
- (void)setIadDate:(NSDate *)iAdImpressionDate withPurchaseDate:(NSDate *)appPurchaseDate;

@end

@interface ADJActivityHandler : NSObject <ADJActivityHandler>

+ (id<ADJActivityHandler>)handlerWithConfig:(ADJConfig *)adjustConfig;

@end
