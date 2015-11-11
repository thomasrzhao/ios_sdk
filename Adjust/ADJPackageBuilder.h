//
//  ADJPackageBuilder.h
//  adjust GmbH
//
//  Created by Christian Wellenbrock on 03/07/2013.
//  Copyright (c) 2013-2015 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJEvent.h"
#import "ADJConfig.h"
#import "ADJDeviceInfo.h"
#import "ADJActivityState.h"
#import "ADJActivityPackage.h"

@interface ADJPackageBuilder : NSObject

@property (nonatomic, copy) NSDate *purchaseTime;
@property (nonatomic, copy) ADJAttribution *attribution;
@property (nonatomic, retain) NSDictionary* deeplinkParameters;

- (id)initWithDeviceInfo:(ADJDeviceInfo *)deviceInfo
           activityState:(ADJActivityState *)activityState
                  config:(ADJConfig *)adjustConfig
               createdAt:(double)createdAt;

- (ADJActivityPackage *)buildSessionPackage;
- (ADJActivityPackage *)buildAttributionPackage;
- (ADJActivityPackage *)buildEventPackage:(ADJEvent *)event;
- (ADJActivityPackage *)buildClickPackage:(NSString *)clickSource
                                clickTime:(NSDate *)clickTime;

@end
