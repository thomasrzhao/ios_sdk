//
//  ADJAttributionHandlerTests.m
//  adjust GmbH
//
//  Created by Pedro Filipe on 12/12/14.
//  Copyright (c) 2014-2015 adjust GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>

#import "ADJUtil.h"
#import "ADJTestsUtil.h"
#import "ADJLoggerMock.h"
#import "ADJAdjustFactory.h"
#import "ADJAttributionHandler.h"
#import "ADJPackageHandlerMock.h"
#import "ADJTestActivityPackage.h"
#import "ADJActivityHandlerMock.h"
#import "ADJAttributionHandlerMock.h"
#import "NSURLConnection+NSURLConnectionSynchronousLoadingMocking.h"

@interface ADJAttributionHandlerTests : ADJTestActivityPackage

@property (atomic,strong) ADJActivityPackage *attributionPackage;
@property (atomic,strong) ADJActivityHandlerMock *activityHandlerMock;

@end

@implementation ADJAttributionHandlerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [ADJAdjustFactory setLogger:nil];
    [ADJAdjustFactory setPackageHandler:nil];
    [ADJAdjustFactory setAttributionHandler:nil];
    [NSURLConnection reset];

    [super tearDown];
}

- (void)reset {
    self.loggerMock = [[ADJLoggerMock alloc] init];
    [ADJAdjustFactory setLogger:self.loggerMock];

    ADJConfig *config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    self.activityHandlerMock = [[ADJActivityHandlerMock alloc] initWithConfig:config];
    self.attributionPackage = [self getAttributionPackage:config];

    [NSURLConnection reset];
}

- (ADJActivityPackage *)getAttributionPackage:(ADJConfig *)config {
    ADJAttributionHandlerMock *attributionHandlerMock = [ADJAttributionHandlerMock alloc];
    [ADJAdjustFactory setAttributionHandler:attributionHandlerMock];

    ADJPackageHandlerMock *packageHandlerMock = [ADJPackageHandlerMock alloc];
    [ADJAdjustFactory setPackageHandler:packageHandlerMock];

    [ADJAdjustFactory setSessionInterval:-1];
    [ADJAdjustFactory setSubsessionInterval:-1];
    [ADJAdjustFactory setTimerInterval:-1];
    [ADJAdjustFactory setTimerStart:-1];

    [ADJActivityHandler handlerWithConfig:config];
    [NSThread sleepForTimeInterval:2.0];

    ADJActivityPackage *attributionPackage = attributionHandlerMock.attributionPackage;
    ADJPackageFields *fields = [ADJPackageFields fields];

    [self testAttributionPackage:attributionPackage fields:fields];
    [self.loggerMock reset];

    return attributionPackage;
}

- (void)testGetAttribution {
    //  Reseting to make the test order independent.
    [self reset];

    id<ADJAttributionHandler> attributionHandler = [ADJAttributionHandler handlerWithActivityHandler:self.activityHandlerMock
                                                                              withAttributionPackage:self.attributionPackage
                                                                                         startPaused:NO
                                                                                         hasDelegate:YES];

    // Test null response without error.
    [self checkGetAttributionResponse:attributionHandler responseType:ADJResponseTypeNil];

    // Check empty error.
    aError(@"Failed to get attribution (empty error)");

    // Check response was not logged.
    anVerbose(@"Response");

    // Test client exception.
    [self checkGetAttributionResponse:attributionHandler responseType:ADJResponseTypeConnError];

    // Check the client error.
    aError(@"Failed to get attribution (connection error)");

    // Test wrong json response.
    [self checkGetAttributionResponse:attributionHandler responseType:ADJResponseTypeWrongJson];

    aVerbose(@"Response: not a json response");

    aError(@"Failed to parse json response. (The data couldn’t be read because it isn’t in the correct format.)");

    // Test empty response.
    [self checkGetAttributionResponse:attributionHandler responseType:ADJResponseTypeEmptyJson];

    aVerbose(@"Response: { }");

    aInfo(@"No message found");

    // Check attribution was called without ask_in.
    aTest(@"ActivityHandler updateAttribution, (null)");

    aTest(@"ActivityHandler setAskingAttribution, 0");

    // Test server error.
    [self checkGetAttributionResponse:attributionHandler responseType:ADJResponseTypeServerError];

    // The response logged.
    aVerbose(@"Response: { \"message\": \"testResponseError\"}");

    // The message in the response.
    aError(@"testResponseError");

    // Check attribution was called without ask_in.
    aTest(@"ActivityHandler updateAttribution, (null)");

    aTest(@"ActivityHandler setAskingAttribution, 0");

    // Test ok response with message.
    [self checkGetAttributionResponse:attributionHandler responseType:ADJResponseTypeMessage];
    [self checkOkMessageGetAttributionResponse];
}

- (void)testCheckAttribution {
    // Reseting to make the test order independent.
    [self reset];

    id<ADJAttributionHandler> attributionHandler = [ADJAttributionHandler handlerWithActivityHandler:self.activityHandlerMock
                                                                              withAttributionPackage:self.attributionPackage
                                                                                         startPaused:NO
                                                                                         hasDelegate:YES];

    NSMutableDictionary *attributionDictionary = [[NSMutableDictionary alloc] init];
    [attributionDictionary setObject:@"ttValue" forKey:@"tracker_token"];
    [attributionDictionary setObject:@"tnValue" forKey:@"tracker_name"];
    [attributionDictionary setObject:@"nValue"  forKey:@"network"];
    [attributionDictionary setObject:@"cpValue" forKey:@"campaign"];
    [attributionDictionary setObject:@"aValue"  forKey:@"adgroup"];
    [attributionDictionary setObject:@"ctValue" forKey:@"creative"];
    [attributionDictionary setObject:@"clValue" forKey:@"click_label"];

    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:attributionDictionary forKey:@"attribution"];

    [attributionHandler checkAttribution:jsonDictionary];
    [NSThread sleepForTimeInterval:1.0];

    // Check attribution was called without ask_in.
    aTest(@"ActivityHandler updateAttribution, tt:ttValue tn:tnValue net:nValue cam:cpValue adg:aValue cre:ctValue cl:clValue");

    // Updated set askingAttribution to false.
    aTest(@"ActivityHandler setAskingAttribution, 0");

    // It did not update to true.
    anTest(@"ActivityHandler setAskingAttribution, 1");

    // And waiting for query.
    anDebug(@"Waiting to query attribution");
}

- (void)testAskIn {
    // Reseting to make the test order independent.
    [self reset];

    id<ADJAttributionHandler> attributionHandler = [ADJAttributionHandler handlerWithActivityHandler:self.activityHandlerMock
                                                                              withAttributionPackage:self.attributionPackage
                                                                                         startPaused:NO
                                                                                         hasDelegate:YES];

    NSMutableDictionary *askIn4sDictionary = [[NSMutableDictionary alloc] init];
    [askIn4sDictionary setObject:@"4000" forKey:@"ask_in"];

    // Set null response to avoid a cycle.
    [NSURLConnection setResponseType:ADJResponseTypeMessage];

    [attributionHandler checkAttribution:askIn4sDictionary];

    // Sleep enough not to trigger the timer.
    [NSThread sleepForTimeInterval:1.0];

    // Check attribution was called with ask_in.
    anTest(@"ActivityHandler updateAttribution");

    // It did update to true.
    aTest(@"ActivityHandler setAskingAttribution, 1");

    // And waited to for query.
    aDebug(@"Waiting to query attribution in 4000 milliseconds");

    // Sleep enough not to trigger the timer.
    [NSThread sleepForTimeInterval:1.0];

    NSMutableDictionary *askIn5sDictionary = [[NSMutableDictionary alloc] init];
    [askIn5sDictionary setObject:@"5000" forKey:@"ask_in"];

    [attributionHandler checkAttribution:askIn5sDictionary];

    // Sleep enough not to trigger the old timer.
    [NSThread sleepForTimeInterval:3.0];

    // It did update to true.
    aTest(@"ActivityHandler setAskingAttribution, 1");

    // And waited to for query.
    aDebug(@"Waiting to query attribution in 5000 milliseconds");

    // It was been waiting for 1000 + 2000 + 3000 = 6 seconds.
    // Check that the mock http client was not called because the original clock was reseted.
    anTest(@"NSURLConnection sendSynchronousRequest");

    // Check that it was finally called after 7 seconds after the second ask_in.
    [NSThread sleepForTimeInterval:4.0];

    // Test ok response with message.
    aTest(@"NSURLConnection sendSynchronousRequest");

    [self checkOkMessageGetAttributionResponse];
    [self checkRequest:[NSURLConnection getLastRequest]];
}

- (void)testPause {
    // Reseting to make the test order independent.
    [self reset];

    id<ADJAttributionHandler> attributionHandler = [ADJAttributionHandler handlerWithActivityHandler:self.activityHandlerMock
                                                                              withAttributionPackage:self.attributionPackage
                                                                                         startPaused:YES
                                                                                         hasDelegate:YES];

    [NSURLConnection setResponseType:ADJResponseTypeMessage];

    [attributionHandler getAttribution];

    [NSThread sleepForTimeInterval:1.0];

    // Check that the activity handler is paused.
    aDebug(@"Attribution handler is paused");

    // And it did not call the http client.
    aNil([NSURLConnection getLastRequest]);

    anTest(@"NSURLConnection sendSynchronousRequest");
}

- (void)testWithoutListener {
    // Reseting to make the test order independent
    [self reset];

    id<ADJAttributionHandler> attributionHandler = [ADJAttributionHandler handlerWithActivityHandler:self.activityHandlerMock
                                                                              withAttributionPackage:self.attributionPackage
                                                                                         startPaused:NO
                                                                                         hasDelegate:NO];

    [NSURLConnection setResponseType:ADJResponseTypeMessage];

    [attributionHandler getAttribution];

    [NSThread sleepForTimeInterval:1.0];

    // Check that the activity handler is not paused.
    anDebug(@"Attribution handler is paused");

    // But it did not call the http client.
    aNil([NSURLConnection getLastRequest]);

    anTest(@"NSURLConnection sendSynchronousRequest");
}

- (void)checkOkMessageGetAttributionResponse {
    // The response logged.
    aVerbose(@"Response: { \"message\" : \"response OK\"}");

    // The message in the response.
    aInfo(@"response OK");

    // Check attribution was called without ask_in.
    aTest(@"ActivityHandler updateAttribution, (null)");
    aTest(@"ActivityHandler setAskingAttribution, 0");
}

- (void)checkGetAttributionResponse:(id<ADJAttributionHandler>)attributionHandler
                       responseType:(ADJResponseType)responseType {
    [NSURLConnection setResponseType:responseType];

    [attributionHandler getAttribution];
    [NSThread sleepForTimeInterval:1.0];

    // Delay time is 0.
    anDebug(@"Waiting to query attribution");

    // It tried to send the request.
    aTest(@"NSURLConnection sendSynchronousRequest");

    [self checkRequest:[NSURLConnection getLastRequest]];
}

- (void)checkRequest:(NSURLRequest *)request {
    if (request == nil) {
        return;
    }

    NSURL *url = [request URL];

    aslEquals(@"https", url.scheme, request.description);

    aslEquals(@"app.adjust.com", url.host, request.description);

    aslEquals(@"GET", [request HTTPMethod], request.description);
}

@end
