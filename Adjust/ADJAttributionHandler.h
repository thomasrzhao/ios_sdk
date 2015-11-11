//
//  ADJAttributionHandler.h
//  adjust GmbH
//
//  Created by Pedro Filipe on 29/10/14.
//  Copyright (c) 2014-2015 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJActivityHandler.h"
#import "ADJActivityPackage.h"

@protocol ADJAttributionHandler

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
       withAttributionPackage:(ADJActivityPackage *)attributionPackage
                  startPaused:(BOOL)startPaused
                  hasDelegate:(BOOL)hasDelegate;

- (void)pauseSending;
- (void)resumeSending;
- (void)getAttribution;
- (void)checkAttribution:(NSDictionary *)jsonDict;

@end

@interface ADJAttributionHandler : NSObject <ADJAttributionHandler>

+ (id<ADJAttributionHandler>)handlerWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                                 withAttributionPackage:(ADJActivityPackage *)attributionPackage
                                            startPaused:(BOOL)startPaused
                                            hasDelegate:(BOOL)hasDelegate;

@end
