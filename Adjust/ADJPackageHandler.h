//
//  ADJPackageHandler.h
//  adjust GmbH
//
//  Created by Christian Wellenbrock on 03/07/2013.
//  Copyright (c) 2013-2015 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJPackageHandler.h"
#import "ADJActivityHandler.h"
#import "ADJActivityPackage.h"

@protocol ADJPackageHandler

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                  startPaused:(BOOL)startPaused;

- (void)pauseSending;
- (void)resumeSending;
- (void)sendNextPackage;
- (void)sendFirstPackage;
- (void)closeFirstPackage;
- (void)addPackage:(ADJActivityPackage *)package;
- (void)finishedTracking:(NSDictionary *)jsonDict;

@end

@interface ADJPackageHandler : NSObject <ADJPackageHandler>

+ (id<ADJPackageHandler>)handlerWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                                        startPaused:(BOOL)startPaused;

@end
