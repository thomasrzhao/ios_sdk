//
//  ADJPackageBuilder.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ADJEvent.h"
#import "ADJDeviceInfo.h"
#import "ADJActivityState.h"
#import "ADJActivityPackage.h"
#import "ADJConfig.h"
#import "ADJSessionParameters.h"

@interface ADJPackageBuilder : NSObject

@property (nonatomic, copy) ADJAttribution *attribution;
@property (nonatomic, copy) NSDate *purchaseTime;
@property (nonatomic, copy) NSDate *clickTime;
@property (nonatomic, retain) NSDictionary *iadDetails;
@property (nonatomic, retain) NSDictionary* deeplinkParameters;
@property (nonatomic, copy) NSString *deeplink;
@property (nonatomic, copy) NSString *deviceToken;

- (id) initWithDeviceInfo:(ADJDeviceInfo *)deviceInfo
            activityState:(ADJActivityState *)activityState
                   config:(ADJConfig *)adjustConfig
                createdAt:(double)createdAt;

- (ADJActivityPackage *)buildSessionPackage:(ADJSessionParameters *)sessionParameters
                                  isInDelay:(BOOL)isInDelay;
- (ADJActivityPackage *)buildEventPackage:(ADJEvent *)event
                        sessionParameters:(ADJSessionParameters *)sessionParameters
                                isInDelay:(BOOL)isInDelay;
- (ADJActivityPackage *)buildClickPackage:(NSString *)clickSource;
- (ADJActivityPackage *)buildAttributionPackage;

+ (void)parameters:(NSMutableDictionary *)parameters setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key;
+ (void)parameters:(NSMutableDictionary *)parameters setString:(NSString *)value forKey:(NSString *)key;

@end
