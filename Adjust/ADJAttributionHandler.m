//
//  ADJAttributionHandler.m
//  adjust GmbH
//
//  Created by Pedro Filipe on 29/10/14.
//  Copyright (c) 2014-2015 adjust GmbH. All rights reserved.
//

#import "ADJUtil.h"
#import "ADJTimerOnce.h"
#import "ADJAdjustFactory.h"
#import "ADJActivityHandler.h"
#import "NSString+ADJAdditions.h"
#import "ADJAttributionHandler.h"

static const double kRequestTimeout             = 60;   // 60 seconds
static const char * const kInternalQueueName    = "com.adjust.AttributionQueue";

@interface ADJAttributionHandler()

@property (nonatomic, assign) BOOL paused;
@property (nonatomic, assign) BOOL hasDelegate;
@property (nonatomic, retain) ADJTimerOnce *timer;
@property (nonatomic) dispatch_queue_t internalQueue;

@property (nonatomic, assign) id<ADJLogger> logger;
@property (nonatomic, assign) id<ADJActivityHandler> activityHandler;
@property (nonatomic, retain) ADJActivityPackage *attributionPackage;

@end

@implementation ADJAttributionHandler

#pragma mark - Object lifecycle

+ (id<ADJAttributionHandler>)handlerWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                                 withAttributionPackage:(ADJActivityPackage *)attributionPackage
                                            startPaused:(BOOL)startPaused
                                            hasDelegate:(BOOL)hasDelegate {
    return [[ADJAttributionHandler alloc] initWithActivityHandler:activityHandler
                                           withAttributionPackage:attributionPackage
                                                      startPaused:startPaused
                                                      hasDelegate:hasDelegate];
}

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
       withAttributionPackage:(ADJActivityPackage *)attributionPackage
                  startPaused:(BOOL)startPaused
                  hasDelegate:(BOOL)hasDelegate {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    self.paused             = startPaused;
    self.logger             = [ADJAdjustFactory logger];
    self.hasDelegate        = hasDelegate;
    self.activityHandler    = activityHandler;
    self.attributionPackage = attributionPackage;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.timer = [ADJTimerOnce timerWithBlock:^{ [self getAttributionInternal]; }
                                        queue:self.internalQueue];

    return self;
}

#pragma mark - Internal methods

- (void)checkAttributionInternal:(NSDictionary *)jsonDict {
    if ([ADJUtil isNull:jsonDict]) {
        return;
    }

    NSDictionary *jsonAttribution = [jsonDict objectForKey:@"attribution"];
    ADJAttribution *attribution = [ADJAttribution dataWithJsonDict:jsonAttribution];
    NSNumber *timerMilliseconds = [jsonDict objectForKey:@"ask_in"];

    if (timerMilliseconds == nil) {
        [self.activityHandler updateAttribution:attribution];
        [self.activityHandler setAskingAttribution:NO];

        return;
    }

    [self.activityHandler setAskingAttribution:YES];
    [self getAttributionWithDelay:[timerMilliseconds intValue]];
}

- (void)getAttributionInternal {
    if (!self.hasDelegate) {
        return;
    }

    if (self.paused) {
        [self.logger debug:@"Attribution handler is paused"];

        return;
    }

    [self.logger verbose:@"%@", self.attributionPackage.extendedString];

    [ADJUtil sendRequest:[self request]
      prefixErrorMessage:@"Failed to get attribution"
     jsonResponseHandler:^(NSDictionary *jsonDict) {
         [self checkAttribution:jsonDict];
     }];
}

#pragma mark - Private methods

- (NSMutableURLRequest *)request {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self url]];
    request.timeoutInterval = kRequestTimeout;
    request.HTTPMethod = @"GET";

    [request setValue:self.attributionPackage.clientSdk forHTTPHeaderField:@"Client-Sdk"];

    return request;
}

- (NSURL *)url {
    NSString *parameters = [ADJUtil queryString:self.attributionPackage.parameters];
    NSString *relativePath = [NSString stringWithFormat:@"%@?%@", self.attributionPackage.path, parameters];

    NSURL *baseUrl = [NSURL URLWithString:ADJUtil.baseUrl];
    NSURL *url = [NSURL URLWithString:relativePath relativeToURL:baseUrl];
    
    return url;
}

- (void)getAttributionWithDelay:(int)milliSecondsDelay {
    NSTimeInterval secondsDelay = milliSecondsDelay / 1000;
    NSTimeInterval nextAskIn = [self.timer fireIn];

    if (nextAskIn > secondsDelay) {
        return;
    }

    if (milliSecondsDelay > 0) {
        [self.logger debug:@"Waiting to query attribution in %d milliseconds", milliSecondsDelay];
    }

    // Set the new time the timer will fire in.
    [self.timer startIn:secondsDelay];
}

#pragma mark - Public methods

- (void)pauseSending {
    self.paused = YES;
}

- (void)resumeSending {
    self.paused = NO;
}

- (void)getAttribution {
    [self getAttributionWithDelay:0];
}

- (void)checkAttribution:(NSDictionary *)jsonDict {
    dispatch_async(self.internalQueue, ^{
        [self checkAttributionInternal:jsonDict];
    });
}

@end
