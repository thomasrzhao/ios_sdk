//
//  ADJRequestHandlerTests.m
//  adjust GmbH
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014-2015 adjust GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ADJTestsUtil.h"
#import "ADJLoggerMock.h"
#import "ADJAdjustFactory.h"
#import "ADJPackageHandlerMock.h"
#import "ADJRequestHandlerMock.h"
#import "ADJTestActivityPackage.h"
#import "NSURLConnection+NSURLConnectionSynchronousLoadingMocking.h"

@interface ADJRequestHandlerTests : ADJTestActivityPackage

@property (atomic, strong) id<ADJRequestHandler> requestHandler;
@property (atomic, strong) ADJPackageHandlerMock *packageHandlerMock;

@end

@implementation ADJRequestHandlerTests

- (void)setUp {
    [super setUp];
    [self reset];
}

- (void)tearDown {
    [ADJAdjustFactory setLogger:nil];
    [super tearDown];
}

- (void)reset {
    self.loggerMock = [[ADJLoggerMock alloc] init];
    [ADJAdjustFactory setLogger:self.loggerMock];

    self.packageHandlerMock = [[ADJPackageHandlerMock alloc] init];
    [ADJAdjustFactory setPackageHandler:self.packageHandlerMock];

    self.requestHandler =[ADJAdjustFactory requestHandlerForPackageHandler:self.packageHandlerMock];
}

- (void)testSend {
    // null response
    [NSURLConnection setResponseType:ADJResponseTypeNil];

    [self checkSendPackage];

    aTest(@"PackageHandler closeFirstPackage");

    // Client exception
    [NSURLConnection setResponseType:ADJResponseTypeConnError];

    [self checkSendPackage];

    aError(@"Failed to track unknown (connection error) Will retry later");

    aTest(@"PackageHandler closeFirstPackage");

    // Server error
    [NSURLConnection setResponseType:ADJResponseTypeServerError];

    [self checkSendPackage];

    aVerbose(@"Response: { \"message\": \"testResponseError\"}");

    aError(@"testResponseError");

    aTest(@"PackageHandler finishedTracking, \"message\" = \"testResponseError\";");

    aTest(@"PackageHandler sendNextPackage");

    // Wrong json
    [NSURLConnection setResponseType:ADJResponseTypeWrongJson];

    [self checkSendPackage];

    aVerbose(@"Response: not a json response");

    aError(@"Failed to parse json response. (The data couldn’t be read because it isn’t in the correct format.)");

    aTest(@"PackageHandler closeFirstPackage");

    // Empty json
    [NSURLConnection setResponseType:ADJResponseTypeEmptyJson];

    [self checkSendPackage];

    aVerbose(@"Response: { }");

    aInfo(@"No message found");

    aTest(@"PackageHandler finishedTracking, ");

    aTest(@"PackageHandler sendNextPackage");

    // Message response
    [NSURLConnection setResponseType:ADJResponseTypeMessage];

    [self checkSendPackage];

    aVerbose(@"Response: { \"message\" : \"response OK\"}");

    aInfo(@"response OK");

    aTest(@"PackageHandler finishedTracking, \"message\" = \"response OK\";");

    aTest(@"PackageHandler sendNextPackage");
}

- (void)checkSendPackage {
    [self.requestHandler sendPackage:[ADJTestsUtil getUnknowPackage:@""]];

    [NSThread sleepForTimeInterval:1.0];

    aTest(@"NSURLConnection sendSynchronousRequest");
}

@end
