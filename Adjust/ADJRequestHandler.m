//
//  ADJRequestHandler.m
//  adjust GmbH
//
//  Created by Christian Wellenbrock on 04/07/2013.
//  Copyright (c) 2013-2015 adjust GmbH. All rights reserved.
//

#import "ADJUtil.h"
#import "ADJLogger.h"
#import "ADJActivityKind.h"
#import "ADJAdjustFactory.h"
#import "ADJActivityPackage.h"
#import "NSString+ADJAdditions.h"

static const double kRequestTimeout             = 60;   // 60 seconds
static const char * const kInternalQueueName    = "io.adjust.RequestQueue";

@interface ADJRequestHandler()

@property (nonatomic, retain) NSURL *baseUrl;
@property (nonatomic) dispatch_queue_t internalQueue;

@property (nonatomic, assign) id<ADJLogger> logger;
@property (nonatomic, assign) id<ADJPackageHandler> packageHandler;

@end

@implementation ADJRequestHandler

#pragma mark - Object lifecycle

+ (ADJRequestHandler *)handlerWithPackageHandler:(id<ADJPackageHandler>)packageHandler {
    return [[ADJRequestHandler alloc] initWithPackageHandler:packageHandler];
}

- (id)initWithPackageHandler:(id<ADJPackageHandler>)packageHandler {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    self.internalQueue  = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.packageHandler = packageHandler;
    self.logger         = [ADJAdjustFactory logger];
    self.baseUrl        = [NSURL URLWithString:ADJUtil.baseUrl];

    return self;
}

#pragma mark - Public methods

- (void)sendPackage:(ADJActivityPackage *)activityPackage {
    dispatch_async(self.internalQueue, ^{
        [self sendInternal:activityPackage];
    });
}

#pragma mark - Internal methods
- (void)sendInternal:(ADJActivityPackage *)package {
    [ADJUtil sendRequest:[self requestForPackage:package]
      prefixErrorMessage:package.failureMessage
      suffixErrorMessage:@"Will retry later"
     jsonResponseHandler:^(NSDictionary *jsonDict) {
         if (jsonDict == nil) {
             [self.packageHandler closeFirstPackage];
             return;
         }

         [self.packageHandler finishedTracking:jsonDict];
         [self.packageHandler sendNextPackage];
     }];
}

#pragma mark - Private methods
- (NSMutableURLRequest *)requestForPackage:(ADJActivityPackage *)package {
    NSURL *url = [NSURL URLWithString:package.path relativeToURL:self.baseUrl];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = kRequestTimeout;
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:package.clientSdk forHTTPHeaderField:@"Client-Sdk"];
    [request setHTTPBody:[self bodyForParameters:package.parameters]];

    return request;
}

- (NSData *)bodyForParameters:(NSDictionary *)parameters {
    NSString *bodyString = [ADJUtil queryString:parameters];
    NSData *body = [NSData dataWithBytes:bodyString.UTF8String length:bodyString.length];

    return body;
}

@end
