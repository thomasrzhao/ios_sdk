//
//  ADJAttributionHandlerMock.m
//  adjust GmbH
//
//  Created by Pedro Filipe on 10/12/14.
//  Copyright (c) 2014-2015 adjust GmbH. All rights reserved.
//

#import "ADJLoggerMock.h"
#import "ADJAdjustFactory.h"
#import "ADJAttributionHandlerMock.h"

static NSString * const prefix = @"AttributionHandler ";

@interface ADJAttributionHandlerMock()

@property (nonatomic, assign) BOOL startPaused;
@property (nonatomic, assign) BOOL hasDelegate;
@property (nonatomic, strong) ADJLoggerMock *loggerMock;

@end

@implementation ADJAttributionHandlerMock

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
       withAttributionPackage:(ADJActivityPackage *)attributionPackage
                  startPaused:(BOOL)startPaused
                  hasDelegate:(BOOL)hasDelegate {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    self.startPaused        = startPaused;
    self.hasDelegate        = hasDelegate;
    self.loggerMock         = (ADJLoggerMock *)[ADJAdjustFactory logger];
    self.attributionPackage = attributionPackage;

    [self.loggerMock test:[prefix stringByAppendingFormat:@"initWithActivityHandler"]];

    return self;
}

- (void)checkAttribution:(NSDictionary *)jsonDict {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"checkAttribution, jsonDict: %@", jsonDict]];
}

- (void)getAttribution {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"getAttribution"]];
}

- (void)pauseSending {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"pauseSending"]];
}

- (void)resumeSending {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"resumeSending"]];
}

@end
