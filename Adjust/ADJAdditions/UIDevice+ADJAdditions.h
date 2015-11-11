//
//  UIDevice+ADJAdditions.h
//  adjust GmbH
//
//  Created by Christian Wellenbrock on 23/07/12.
//  Copyright (c) 2012-2015 adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "ADJActivityHandler.h"

@interface UIDevice(ADJAdditions)

- (BOOL)adjTrackingEnabled;

- (NSString *)adjVendorId;
- (NSString *)adjMacAddress;
- (NSString *)adjDeviceType;
- (NSString *)adjDeviceName;
- (NSString *)adjCreateUuid;
- (NSString *)adjFbAttributionId;
- (NSString *)adjIdForAdvertisers;

- (void)adjSetIad:(ADJActivityHandler *)activityHandler;

@end
