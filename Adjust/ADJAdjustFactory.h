//
//  ADJAdjustFactory.h
//  adjust GmbH
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014-2015 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJLogger.h"
#import "ADJPackageHandler.h"
#import "ADJRequestHandler.h"
#import "ADJActivityHandler.h"
#import "ADJActivityPackage.h"
#import "ADJAttributionHandler.h"

@interface ADJAdjustFactory : NSObject

+ (id<ADJLogger>)logger;
+ (id<ADJActivityHandler>)activityHandlerWithConfig:(ADJConfig *)adjustConfig;
+ (id<ADJRequestHandler>)requestHandlerForPackageHandler:(id<ADJPackageHandler>)packageHandler;
+ (id<ADJPackageHandler>)packageHandlerForActivityHandler:(id<ADJActivityHandler>)activityHandler
                                              startPaused:(BOOL)startPaused;
+ (id<ADJAttributionHandler>)attributionHandlerForActivityHandler:(id<ADJActivityHandler>)activityHandler
                                           withAttributionPackage:(ADJActivityPackage *)attributionPackage
                                                      startPaused:(BOOL)startPaused
                                                      hasDelegate:(BOOL)hasDelegate;

+ (double)sessionInterval;
+ (double)subsessionInterval;

+ (NSTimeInterval)timerStart;
+ (NSTimeInterval)timerInterval;

+ (void)setLogger:(id<ADJLogger>)logger;
+ (void)setPackageHandler:(id<ADJPackageHandler>)packageHandler;
+ (void)setRequestHandler:(id<ADJRequestHandler>)requestHandler;
+ (void)setActivityHandler:(id<ADJActivityHandler>)activityHandler;
+ (void)setAttributionHandler:(id<ADJAttributionHandler>)attributionHandler;

+ (void)setSessionInterval:(double)sessionInterval;
+ (void)setSubsessionInterval:(double)subsessionInterval;

+ (void)setTimerStart:(NSTimeInterval)timerStart;
+ (void)setTimerInterval:(NSTimeInterval)timerInterval;

@end
