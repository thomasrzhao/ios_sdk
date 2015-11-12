//
//  ADJActivityHandlerTests.m
//  adjust GmbH
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014-2015 adjust GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ADJUtil.h"
#import "ADJLogger.h"
#import "ADJConfig.h"
#import "ADJTestsUtil.h"
#import "ADJLoggerMock.h"
#import "ADJDelegateTest.h"
#import "ADJAdjustFactory.h"
#import "ADJActivityHandler.h"
#import "ADJActivityPackage.h"
#import "ADJPackageHandlerMock.h"
#import "ADJTestActivityPackage.h"
#import "ADJAttributionHandlerMock.h"

@interface ADJActivityHandlerTests : ADJTestActivityPackage

@property (atomic,strong) ADJPackageHandlerMock *packageHandlerMock;
@property (atomic,strong) ADJAttributionHandlerMock *attributionHandlerMock;

@end

@implementation ADJActivityHandlerTests

- (void)setUp {
    [super setUp];

    // Check the server url.
    XCTAssertEqual(@"https://app.adjust.com", ADJUtil.baseUrl);
}

- (void)tearDown {
    [ADJAdjustFactory setPackageHandler:nil];
    [ADJAdjustFactory setLogger:nil];
    [ADJAdjustFactory setSessionInterval:-1];
    [ADJAdjustFactory setSubsessionInterval:-1];
    [ADJAdjustFactory setTimerInterval:-1];
    [ADJAdjustFactory setTimerStart:-1];
    [ADJAdjustFactory setAttributionHandler:nil];

    [super tearDown];
}

- (void)reset {
    self.loggerMock = [[ADJLoggerMock alloc] init];
    [ADJAdjustFactory setLogger:self.loggerMock];

    self.packageHandlerMock = [ADJPackageHandlerMock alloc];
    [ADJAdjustFactory setPackageHandler:self.packageHandlerMock];

    [ADJAdjustFactory setSessionInterval:-1];
    [ADJAdjustFactory setSubsessionInterval:-1];
    [ADJAdjustFactory setTimerInterval:-1];
    [ADJAdjustFactory setTimerStart:-1];

    self.attributionHandlerMock = [ADJAttributionHandlerMock alloc];
    [ADJAdjustFactory setAttributionHandler:self.attributionHandlerMock];

    // Starting from a clean slate.
    XCTAssert([ADJTestsUtil deleteFile:@"AdjustIoActivityState" logger:self.loggerMock], @"%@", self.loggerMock);
    XCTAssert([ADJTestsUtil deleteFile:@"AdjustIoAttribution" logger:self.loggerMock], @"%@", self.loggerMock);
}

- (void)testFirstSession {
    // Reseting to make the test order independent.
    [self reset];

    // Create the config to start the session.
    ADJConfig *config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // Create handler and start the first session.
    [ADJActivityHandler handlerWithConfig:config];

    // It's necessary to sleep the activity for a while after each handler call
    // to let the internal queue act.
    [NSThread sleepForTimeInterval:2.0];

    // Test init values.
    [self checkInit:ADJEnvironmentSandbox logLevel:@"3"];

    // Check mac mad5 is enabled.
    anInfo(@"Tracking of macMd5 is disabled");

    // Check event buffering is disabled.
    anInfo(@"Event buffering is enabled");

    // Check does not have default tracker.
    anInfo(@"Default tracker:");

    // Test first session start.
    [self checkFirstSession];

    // Checking the default values of the first session package
    // should only have one package.
    aiEquals(1, (int)[self.packageHandlerMock.packageQueue count]);

    ADJActivityPackage *activityPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[0];

    // Create activity package test.
    ADJPackageFields *fields = [ADJPackageFields fields];

    // Set first session.
    [self testPackageSession:activityPackage fields:fields sessionCount:@"1"];
}

- (void)testEventBuffered {
    // Reseting to make the test order independent.
    [self reset];

    // Create the config to start the session.
    ADJConfig *config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // Buffer events
    config.eventBufferingEnabled = YES;

    // Set verbose log level.
    config.logLevel = ADJLogLevelVerbose;

    // Set default tracker.
    [config setDefaultTracker:@"default1234tracker"];

    // Set macMd5 disabled.
    [config setMacMd5TrackingEnabled:NO];

    // Create handler and start the first session.
    id<ADJActivityHandler> activityHandler = [ADJActivityHandler handlerWithConfig:config];

    [NSThread sleepForTimeInterval:2.0];

    // Test init values.
    [self checkInit:ADJEnvironmentSandbox logLevel:@"1"];

    // Check mac mad5 is disabled.
    aInfo(@"Tracking of macMd5 is disabled");

    // Check event buffering is enabled.
    aInfo(@"Event buffering is enabled");

    // Check does have default tracker.
    aInfo(@"Default tracker: default1234tracker");

    // Test first session start.
    [self checkFirstSession];

    // Create the first Event object with callback and partner parameters.
    ADJEvent *firstEvent = [ADJEvent eventWithEventToken:@"event1"];

    // Add callback parameters.
    [firstEvent addCallbackParameter:@"keyCall" value:@"valueCall"];
    [firstEvent addCallbackParameter:@"keyCall" value:@"valueCall2"];
    [firstEvent addCallbackParameter:@"fooCall" value:@"barCall"];

    // Add partner paramters.
    [firstEvent addPartnerParameter:@"keyPartner" value:@"valuePartner"];
    [firstEvent addPartnerParameter:@"keyPartner" value:@"valuePartner2"];
    [firstEvent addPartnerParameter:@"fooPartner" value:@"barPartner"];

    // Check that callback parameter was overwritten.
    aWarn(@"key keyCall was overwritten");

    // Check that partner parameter was overwritten.
    aWarn(@"key keyPartner was overwritten");

    // Add revenue.
    [firstEvent setRevenue:0.001 currency:@"EUR"];

    // Set transaction id.
    [firstEvent setReceipt:[[NSData alloc] init] transactionId:@"t_id_1"];

    // Track the first event.
    [activityHandler trackEvent:firstEvent];

    [NSThread sleepForTimeInterval:2];

    // Check that event package was added.
    aTest(@"PackageHandler addPackage");

    // Check that event was buffered.
    aInfo(@"Buffered event (0.00100 EUR, 'event1')");

    // And not sent to package handler.
    anTest(@"PackageHandler sendFirstPackage");

    // After tracking the event it should write the activity state.
    aDebug(@"Wrote Activity state: ec:1");

    // Create a second Event object to be discarded with duplicated transaction id.
    ADJEvent *secondEvent = [ADJEvent eventWithEventToken:@"event2"];

    // Set the same id.
    [secondEvent setTransactionId:@"t_id_1"];

    // Track the second event.
    [activityHandler trackEvent:secondEvent];

    [NSThread sleepForTimeInterval:2];

    // Dropping duplicate transaction id.
    aInfo(@"Skipping duplicate transaction ID 't_id_1'");

    aVerbose(@"Found transaction ID in (");

    // Create a third Event object with receipt.
    ADJEvent *thirdEvent = [ADJEvent eventWithEventToken:@"event3"];

    // Add revenue.
    [thirdEvent setRevenue:0 currency:@"USD"];

    // Add receipt information.
    [thirdEvent setReceipt:[@"{ \"transaction-id\" = \"t_id_2\"; }" dataUsingEncoding:NSUTF8StringEncoding] transactionId:@"t_id_2"];

    // Track the third event.
    [activityHandler trackEvent:thirdEvent];

    [NSThread sleepForTimeInterval:2];

    // Check that event package was added.
    aTest(@"PackageHandler addPackage");

    // Check that event was buffered.
    aInfo(@"Buffered event (0.00000 USD, 'event3')");

    // And not sent to package handler.
    anTest(@"PackageHandler sendFirstPackage");

    // After tracking the event it should write the activity state.
    aDebug(@"Wrote Activity state: ec:2");

    // Create a forth Event object without revenue.
    ADJEvent *forthEvent = [ADJEvent eventWithEventToken:@"event4"];

    // Test push token.
    const char bytes[] = "\xFC\x07\x21\xB6\xDF\xAD\x5E\xE1\x10\x97\x5B\xB2\xA2\x63\xDE\x00\x61\xCC\x70\x5B\x4A\x85\xA8\xAE\x3C\xCF\xBE\x7A\x66\x2F\xB1\xAB";
    [activityHandler setDeviceToken:[NSData dataWithBytes:bytes length:(sizeof(bytes) - 1)]];

    // Track the forth event.
    [activityHandler trackEvent:forthEvent];

    [NSThread sleepForTimeInterval:2];

    // Check that event package was added.
    aTest(@"PackageHandler addPackage");

    // Check that event was buffered.
    aInfo(@"Buffered event 'event4'");

    // And not sent to package handler.
    anTest(@"PackageHandler sendFirstPackage");

    // After tracking the event it should write the activity state.
    aDebug(@"Wrote Activity state: ec:3");

    // Check the number of activity packages.
    // 1 session + 3 events
    aiEquals(4, (int)[self.packageHandlerMock.packageQueue count]);

    // Get the session package.
    ADJActivityPackage *sessionPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[0];

    // Create activity package test.
    ADJPackageFields *firstSessionPackageFields = [ADJPackageFields fields];
    firstSessionPackageFields.defaultTracker = @"default1234tracker";

    // Test first session.
    [self testPackageSession:sessionPackage fields:firstSessionPackageFields sessionCount:@"1"];

    // Get the first event.
    ADJActivityPackage *firstEventPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[1];

    // Create event package test.
    ADJPackageFields *firstPackageFields = [ADJPackageFields fields];

    // Set event test parameters.
    firstPackageFields.eventCount = @"1";
    firstPackageFields.revenue = @"0.00100";
    firstPackageFields.currency = @"EUR";
    firstPackageFields.callbackParameters = @"{\"keyCall\":\"valueCall2\",\"fooCall\":\"barCall\"}";
    firstPackageFields.partnerParameters = @"{\"keyPartner\":\"valuePartner2\",\"fooPartner\":\"barPartner\"}";
    firstPackageFields.suffix = @"(0.00100 EUR, 'event1')";

    // Test first event.
    [self testEventSession:firstEventPackage fields:firstPackageFields eventToken:@"event1"];

    // Third event.
    ADJActivityPackage *thirdEventPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[2];

    // Create event package test.
    ADJPackageFields *thirdPackageFields = [ADJPackageFields fields];

    // Set event test parameters.
    thirdPackageFields.eventCount = @"2";
    thirdPackageFields.revenue = @"0.00000";
    thirdPackageFields.currency = @"USD";
    thirdPackageFields.suffix = @"(0.00000 USD, 'event3')";
    thirdPackageFields.receipt = @"eyAidHJhbnNhY3Rpb24taWQiID0gInRfaWRfMiI7IH0";

    // Test third event.
    [self testEventSession:thirdEventPackage fields:thirdPackageFields eventToken:@"event3"];

    // Fourth event.
    ADJActivityPackage *fourthEventPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[3];

    // Create event package test.
    ADJPackageFields *fourthPackageFields = [ADJPackageFields fields];

    // Set event test parameters.
    fourthPackageFields.eventCount = @"3";
    fourthPackageFields.suffix = @"'event4'";
    fourthPackageFields.pushToken = @"fc0721b6dfad5ee110975bb2a263de0061cc705b4a85a8ae3ccfbe7a662fb1ab";

    // Test fourth event.
    [self testEventSession:fourthEventPackage fields:fourthPackageFields eventToken:@"event4"];
}

- (void)testChecks {
    // Reseting to make the test order independent.
    [self reset];

    // Create the config with null app token.
    ADJConfig *nilAppTokenConfig = [ADJConfig configWithAppToken:nil environment:ADJEnvironmentSandbox];

    aError(@"Missing App Token");
    aFalse(nilAppTokenConfig.isValid);

    // Config with wrong size app token.
    ADJConfig *sizeAppTokenConfig = [ADJConfig configWithAppToken:@"1234567890123" environment:ADJEnvironmentSandbox];

    aError(@"Malformed App Token '1234567890123'");
    aFalse(sizeAppTokenConfig.isValid);

    // Config with null environment.
    ADJConfig *nilEnvironmentConfig = [ADJConfig configWithAppToken:@"123456789012" environment:nil];

    aError(@"Missing environment");
    aFalse(nilEnvironmentConfig.isValid);

    // Create the config with environment not standard.
    ADJConfig *wrongEnvironmentConfig = [ADJConfig configWithAppToken:@"123456789012" environment:@"Other"];

    aError(@"Unknown environment 'Other'");
    aFalse(wrongEnvironmentConfig.isValid);

    // Activity handler created with a nil config.
    id<ADJActivityHandler> nilConfigActivityHandler = [ADJActivityHandler handlerWithConfig:nil];

    aError(@"AdjustConfig missing");
    aNil(nilConfigActivityHandler);

    // Activity handler created with an invalid config.
    id<ADJActivityHandler> invalidConfigActivityHandler = [ADJActivityHandler handlerWithConfig:nilAppTokenConfig];

    aError(@"AdjustConfig not initialized correctly");
    aNil(invalidConfigActivityHandler);

    // Event with nil token.
    ADJEvent *nilTokenEvent = [ADJEvent eventWithEventToken:nil];

    aError(@"Missing Event Token");
    aFalse(nilTokenEvent.isValid);

    // Event with malformed token.
    ADJEvent *malformedTokenEvent = [ADJEvent eventWithEventToken:@"event1x"];

    aError(@"Malformed Event Token 'event1x'");
    aFalse(malformedTokenEvent.isValid);

    // Create the config to start the session.
    ADJConfig *config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // Set the log level.
    config.logLevel = ADJLogLevelDebug;

    // Set the delegate that doesn't implement the optional selector.
    ADJTestsUtil *delegateNotImpl = [[ADJTestsUtil alloc] init];
    [config setDelegate:delegateNotImpl];

    aError(@"Delegate does not implement AdjustDelegate");

    // Create handler and start the first session.
    id<ADJActivityHandler> activityHandler =[ADJActivityHandler handlerWithConfig:config];

    [NSThread sleepForTimeInterval:2];

    // Test init values.
    [self checkInit:ADJEnvironmentSandbox logLevel:@"2"];

    // Test first session start.
    [self checkFirstSession];

    // Track null event.
    [activityHandler trackEvent:nil];

    [NSThread sleepForTimeInterval:1];

    aError(@"Event missing");

    // Track invalid event.
    [activityHandler trackEvent:nilTokenEvent];
    [NSThread sleepForTimeInterval:1];

    aError(@"Event not initialized correctly");

    // Create the first Event object.
    ADJEvent *firstEvent = [ADJEvent eventWithEventToken:@"event1"];

    // Event with negative revenue.
    [firstEvent setRevenue:-0.0001 currency:@"EUR"];

    aError(@"Invalid amount -0.00010");

    // Event with null currency.
    [firstEvent setRevenue:0 currency:nil];

    aError(@"Currency must be set with revenue");

    // Event with empty currency.
    [firstEvent setRevenue:0 currency:@""];

    aError(@"Currency is empty");

    // Callback parameter null key.
    [firstEvent addCallbackParameter:nil value:@"valueCall"];

    aError(@"Callback parameter key is missing");

    // Callback parameter empty key.
    [firstEvent addCallbackParameter:@"" value:@"valueCall"];

    aError(@"Callback parameter key is empty");

    // Callback parameter null value.
    [firstEvent addCallbackParameter:@"keyCall" value:nil];

    aError(@"Callback parameter value is missing");

    // Callback parameter empty value.
    [firstEvent addCallbackParameter:@"keyCall" value:@""];

    aError(@"Callback parameter value is empty");

    // Partner parameter null key.
    [firstEvent addPartnerParameter:nil value:@"valuePartner"];

    aError(@"Partner parameter key is missing");

    // Partner parameter empty key.
    [firstEvent addPartnerParameter:@"" value:@"valuePartner"];

    aError(@"Partner parameter key is empty");

    // Partner parameter null value.
    [firstEvent addPartnerParameter:@"keyPartner" value:nil];

    aError(@"Partner parameter value is missing");

    // Partner parameter empty value.
    [firstEvent addPartnerParameter:@"keyPartner" value:@""];

    aError(@"Partner parameter value is empty");

    // Receipt without transaction id.
    [firstEvent setReceipt:[@"value" dataUsingEncoding:NSUTF8StringEncoding] transactionId:nil];
    
    aError(@"Missing transactionId");

    // Track event without optional parameters.
    [activityHandler trackEvent:firstEvent];
    [NSThread sleepForTimeInterval:1];

    // Check that event package was added.
    aTest(@"PackageHandler addPackage");

    // Check that event was not buffered.
    anInfo(@"Buffered event");

    // Check that event was sent to package handler.
    aTest(@"PackageHandler sendFirstPackage");

    // After tracking the event it should write the activity state.
    aDebug(@"Wrote Activity state: ec:1");

    // Check the number of activity packages.
    // 1 session + 1 event
    aiEquals(2, (int)[self.packageHandlerMock.packageQueue count]);

    // Get the session package.
    ADJActivityPackage *sessionPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[0];

    // Create activity package test.
    ADJPackageFields *sessionPackageFields = [ADJPackageFields fields];
    sessionPackageFields.hasDelegate = @"0";

    // Test first session.
    [self testPackageSession:sessionPackage fields:sessionPackageFields sessionCount:@"1"];

    // Get the first event.
    ADJActivityPackage *eventPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[1];

    // Create event package test.
    ADJPackageFields *eventFields = [ADJPackageFields fields];

    // Set event test parameters.
    eventFields.eventCount = @"1";
    eventFields.suffix = @"'event1'";

    // Test first event.
    [self testEventSession:eventPackage fields:eventFields eventToken:@"event1"];
}

- (void)testSessons {
    // Reseting to make the test order independent.
    [self reset];

    // Adjust the intervals for testing.
    [ADJAdjustFactory setSessionInterval:(4)]; // 4 seconds
    [ADJAdjustFactory setSubsessionInterval:(1)]; // 1 second

    // Create the config to start the session
    ADJConfig *config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // Set verbose log level.
    config.logLevel = ADJLogLevelInfo;

    // Create handler and start the first session.
    id<ADJActivityHandler> activityHandler = [ADJActivityHandler handlerWithConfig:config];

    [NSThread sleepForTimeInterval:2];

    // Test init values.
    [self checkInit:ADJEnvironmentSandbox logLevel:@"3"];

    // Test first session start.
    [self checkFirstSession];

    // Trigger a new sub session session.
    [activityHandler trackSubsessionStart];

    // And end it.
    [activityHandler trackSubsessionEnd];

    [NSThread sleepForTimeInterval:5];

    [self checkSubsession:1 subSessionCount:2 timerAlreadyStarted:YES];
    [self checkEndSession];

    // Trigger a new session.
    [activityHandler trackSubsessionStart];

    [NSThread sleepForTimeInterval:1];

    // New session
    [self checkNewSession:NO sessionCount:2 eventCount:0 timerAlreadyStarted:YES];

    // End the session.
    [activityHandler trackSubsessionEnd];

    [NSThread sleepForTimeInterval:1];

    [self checkEndSession];

    // 2 session packages
    aiEquals(2, (int)[self.packageHandlerMock.packageQueue count]);

    // First session
    ADJActivityPackage *firstSessionPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[0];

    // Create activity package test.
    ADJPackageFields *firstSessionfields = [ADJPackageFields fields];

    // Test first session.
    [self testPackageSession:firstSessionPackage fields:firstSessionfields sessionCount:@"1"];

    // Get second session package.
    ADJActivityPackage *secondSessionPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[1];

    // Create second session test package.
    ADJPackageFields *secondSessionfields = [ADJPackageFields fields];

    // Check if it saved the second subsession in the new package.
    secondSessionfields.subSessionCount = @"2";

    // Test second session.
    [self testPackageSession:secondSessionPackage fields:secondSessionfields sessionCount:@"2"];
}

- (void)testDisable {
    // Reseting to make the test order independent.
    [self reset];

    // Starting from a clean slate.
    XCTAssert([ADJTestsUtil deleteFile:@"AdjustIoActivityState" logger:self.loggerMock], @"%@", self.loggerMock);
    XCTAssert([ADJTestsUtil deleteFile:@"AdjustIoAttribution" logger:self.loggerMock], @"%@", self.loggerMock);

    // Adjust the intervals for testing.
    [ADJAdjustFactory setSessionInterval:(4)]; // 4 seconds
    [ADJAdjustFactory setSubsessionInterval:(1)]; // 1 second

    // Create the config to start the session.
    ADJConfig *config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // Set log level.
    config.logLevel = ADJLogLevelWarn;

    // Start activity handler with config.
    id<ADJActivityHandler> activityHandler = [ADJActivityHandler handlerWithConfig:config];

    // Check that is true by default.
    aTrue([activityHandler isEnabled]);

    // Disable SDK.
    [activityHandler setEnabled:NO];

    // Check that it is disabled.
    aFalse([activityHandler isEnabled]);

    // Not writing activity state because it did not had time to start.
    anDebug(@"Wrote Activity state");

    // Check if message the disable of the SDK.
    aInfo(@"Pausing package handler and attribution handler to disable the SDK");

    // It's necessary to sleep the activity for a while after each handler call
    // to let the internal queue act.
    [NSThread sleepForTimeInterval:2];

    // Test init values.
    [self checkInit:ADJEnvironmentSandbox logLevel:@"4"];

    // Test first session start without attribution handler.
    [self checkFirstSession:YES];

    // Test end session of disable.
    [self checkEndSession];

    // Try to do activities while SDK disabled.
    [activityHandler trackSubsessionStart];
    [activityHandler trackEvent:[ADJEvent eventWithEventToken:@"event1"]];

    [NSThread sleepForTimeInterval:3];

    // Check that timer was not executed.
    anDebug(@"Session timer fired");

    // Check that it did not resume.
    anTest(@"PackageHandler resumeSending");

    // Check that it did not wrote activity state from new session or subsession.
    anDebug(@"Wrote Activity state");

    // Check that it did not add any event package.
    anTest(@"PackageHandler addPackage");

    // Only the first session package should be sent.
    aiEquals(1, (int)[self.packageHandlerMock.packageQueue count]);

    // Put in offline mode.
    [activityHandler setOfflineMode:YES];

    // Pausing due to offline mode.
    aInfo(@"Pausing package and attribution handler to put in offline mode");

    // Wait to update status.
    [NSThread sleepForTimeInterval:6.0];

    // Test end session of offline.
    [self checkEndSession];

    // Re-enable the SDK.
    [activityHandler setEnabled:YES];

    // Check that it is enabled.
    aTrue([activityHandler isEnabled]);

    // Check message of SDK still paused.
    aInfo(@"Package and attribution handler remain paused due to the SDK is offline");

    [activityHandler trackSubsessionStart];

    [NSThread sleepForTimeInterval:1.0];

    [self checkNewSession:YES sessionCount:2 eventCount:0 timerAlreadyStarted:NO];

    // And that the timer is not fired.
    anDebug(@"Session timer fired");
    
    // Track an event.
    [activityHandler trackEvent:[ADJEvent eventWithEventToken:@"event1"]];

    [NSThread sleepForTimeInterval:1.0];

    // Check that it did add the event package.
    aTest(@"PackageHandler addPackage");

    // And send it.
    aTest(@"PackageHandler sendFirstPackage");

    // It should have the second session and the event
    aiEquals(3, (int)[self.packageHandlerMock.packageQueue count]);

    ADJActivityPackage *secondSessionPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[1];

    // Create activity package test.
    ADJPackageFields *secondSessionFields = [ADJPackageFields fields];

    secondSessionFields.subSessionCount = @"1";

    // Set second session.
    [self testPackageSession:secondSessionPackage fields:secondSessionFields sessionCount:@"2"];

    ADJActivityPackage *eventPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[2];

    // Create event package test.
    ADJPackageFields *eventFields = [ADJPackageFields fields];

    eventFields.suffix = @"'event1'";

    // Test event.
    [self testEventSession:eventPackage fields:eventFields eventToken:@"event1"];

    // Put in online mode.
    [activityHandler setOfflineMode:NO];

    // Message that is finally resuming.
    aInfo(@"Resuming package handler and attribution handler to put in online mode");

    [NSThread sleepForTimeInterval:6.0];

    // Check status update.
    aTest(@"AttributionHandler resumeSending");
    aTest(@"PackageHandler resumeSending");

    // Track sub session.
    [activityHandler trackSubsessionStart];

    [NSThread sleepForTimeInterval:1.0];

    // Test sub session not paused.
    [self checkNewSession:NO sessionCount:3 eventCount:1 timerAlreadyStarted:YES];
}

- (void)testAppWillOpenUrl {
    // Reseting to make the test order independent.
    [self reset];

    // Create the config to start the session.
    ADJConfig *config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // Set log level.
    config.logLevel = ADJLogLevelError;

    // Start activity handler with config.
    id<ADJActivityHandler> activityHandler = [ADJActivityHandler handlerWithConfig:config];

    // It's necessary to sleep the activity for a while after each handler call
    // to let the internal queue act.
    [NSThread sleepForTimeInterval:2.0];

    // Test init values.
    [self checkInit:ADJEnvironmentSandbox logLevel:@"5"];

    // Test first sessio.n start
    [self checkFirstSession];

    NSURL *attributions = [NSURL URLWithString:@"AdjustTests://example.com/path/inApp?adjust_tracker=trackerValue&other=stuff&adjust_campaign=campaignValue&adjust_adgroup=adgroupValue&adjust_creative=creativeValue"];
    NSURL *extraParams = [NSURL URLWithString:@"AdjustTests://example.com/path/inApp?adjust_foo=bar&other=stuff&adjust_key=value"];
    NSURL *mixed = [NSURL URLWithString:@"AdjustTests://example.com/path/inApp?adjust_foo=bar&other=stuff&adjust_campaign=campaignValue&adjust_adgroup=adgroupValue&adjust_creative=creativeValue"];
    NSURL *emptyQueryString = [NSURL URLWithString:@"AdjustTests://"];
    NSURL *emptyString = [NSURL URLWithString:@""];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    NSURL *nilString = [NSURL URLWithString:nil];
#pragma clang diagnostic pop
    NSURL *nilUrl = nil;
    NSURL *single = [NSURL URLWithString:@"AdjustTests://example.com/path/inApp?adjust_foo"];
    NSURL *prefix = [NSURL URLWithString:@"AdjustTests://example.com/path/inApp?adjust_=bar"];
    NSURL *incomplete = [NSURL URLWithString:@"AdjustTests://example.com/path/inApp?adjust_foo="];

    [activityHandler appWillOpenUrl:attributions];
    [activityHandler appWillOpenUrl:extraParams];
    [activityHandler appWillOpenUrl:mixed];
    [activityHandler appWillOpenUrl:emptyQueryString];
    [activityHandler appWillOpenUrl:emptyString];
    [activityHandler appWillOpenUrl:nilString];
    [activityHandler appWillOpenUrl:nilUrl];
    [activityHandler appWillOpenUrl:single];
    [activityHandler appWillOpenUrl:prefix];
    [activityHandler appWillOpenUrl:incomplete];

    [NSThread sleepForTimeInterval:2];

    // Three click packages: attributions, extraParams and mixed.
    for (int i = 3; i > 0; i--) {
        aTest(@"PackageHandler addPackage");
    }

    // Checking the default values of the first session package.
    // 1 session + 3 click
    aiEquals(4, (int)[self.packageHandlerMock.packageQueue count]);

    // Get the click package.
    ADJActivityPackage *attributionClickPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[1];

    // Create activity package test.
    ADJPackageFields *attributionClickFields = [ADJPackageFields fields];

    // Create the attribution.
    ADJAttribution *firstAttribution = [[ADJAttribution alloc] init];
    firstAttribution.trackerName = @"trackerValue";
    firstAttribution.campaign = @"campaignValue";
    firstAttribution.adgroup = @"adgroupValue";
    firstAttribution.creative = @"creativeValue";

    // And set it.
    attributionClickFields.attribution = firstAttribution;

    // Test the first deeplink.
    [self testClickPackage:attributionClickPackage fields:attributionClickFields source:@"deeplink"];

    // Get the click package.
    ADJActivityPackage *extraParamsClickPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[2];

    // Create activity package test.
    ADJPackageFields *extraParamsClickFields = [ADJPackageFields fields];

    // Other deep link parameters.
    extraParamsClickFields.deepLinkParameters = @"{\"key\":\"value\",\"foo\":\"bar\"}";

    // Test the second deeplink.
    [self testClickPackage:extraParamsClickPackage fields:extraParamsClickFields source:@"deeplink"];

    // Get the click package.
    ADJActivityPackage *mixedClickPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[3];

    // Create activity package test.
    ADJPackageFields *mixedClickFields = [ADJPackageFields fields];

    // Create the attribution.
    ADJAttribution *secondAttribution = [[ADJAttribution alloc] init];
    secondAttribution.campaign = @"campaignValue";
    secondAttribution.adgroup = @"adgroupValue";
    secondAttribution.creative = @"creativeValue";

    // And set it.
    mixedClickFields.attribution = secondAttribution;

    // Other deep link parameters.
    mixedClickFields.deepLinkParameters = @"{\"foo\":\"bar\"}";

    // Test the third deeplink.
    [self testClickPackage:mixedClickPackage fields:mixedClickFields source:@"deeplink"];
}

- (void)testIad {
    // Reseting to make the test order independent.
    [self reset];

    // Create the config to start the session.
    ADJConfig *config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // Set log level.
    config.logLevel = ADJLogLevelAssert;

    // Start activity handler with config.
    id<ADJActivityHandler> activityHandler = [ADJActivityHandler handlerWithConfig:config];

    // It's necessary to sleep the activity for a while after each handler call
    // to let the internal queue act.
    [NSThread sleepForTimeInterval:2.0];

    // Test init values.
    [self checkInit:ADJEnvironmentSandbox logLevel:@"6"];

    // Test first session start.
    [self checkFirstSession];

    // Should be ignored.
    [activityHandler setIadDate:nil withPurchaseDate:nil];
    [activityHandler setIadDate:nil withPurchaseDate:[NSDate date]];

    [NSThread sleepForTimeInterval:2];

    // Didn't send click package.
    anTest(@"PackageHandler addPackage");

    // 1 session
    aiEquals(1, (int)[self.packageHandlerMock.packageQueue count]);

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'Z"];

    NSDate *date1 = [NSDate date];
    NSString *date1String = [dateFormat stringFromDate:date1];
    NSDate *date2 = [NSDate date];
    NSString *date2String = [dateFormat stringFromDate:date2];

    [self.loggerMock test:@"date1 %@, date2 %@", date1.description, date2.description];

    [activityHandler setIadDate:date1 withPurchaseDate:date2];
    [activityHandler setIadDate:date2 withPurchaseDate:nil];

    [NSThread sleepForTimeInterval:2];

    // First and second iad packages.
    aTest(@"PackageHandler addPackage");
    aTest(@"PackageHandler addPackage");

    // 1 session + 2 click packages
    aiEquals(3, (int)[self.packageHandlerMock.packageQueue count]);

    // First iAd package.
    ADJActivityPackage *firstIadPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[1];

    // Create activity package test.
    ADJPackageFields *firstIadFields = [ADJPackageFields fields];

    firstIadFields.iadTime = date1String;
    firstIadFields.purchaseTime = date2String;

    // Test the click package.
    [self testClickPackage:firstIadPackage fields:firstIadFields source:@"iad"];

    // Second iAd package.
    ADJActivityPackage *secondIadPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[2];

    // Create activity package test.
    ADJPackageFields *secondIadFields = [ADJPackageFields fields];

    secondIadFields.iadTime = date2String;

    // Test the click package.
    [self testClickPackage:secondIadPackage fields:secondIadFields source:@"iad"];
}

- (void)testFinishedTracking {
    // Reseting to make the test order independent.
    [self reset];

    // Create the config to start the session.
    ADJConfig *config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentProduction];

    // Set verbose log level.
    config.logLevel = ADJLogLevelDebug;

    // Set delegate.
    ADJDelegateTest *delegateTests = [[ADJDelegateTest alloc] init];
    [config setDelegate:delegateTests];

    // Create handler and start the first session.
    id<ADJActivityHandler> activityHandler = [ADJActivityHandler handlerWithConfig:config];

    [NSThread sleepForTimeInterval:2.0];

    // Test init values.
    [self checkInit:ADJEnvironmentProduction logLevel:@"6"];

    // Test first session start.
    [self checkFirstSession];

    // Test nil response.
    [activityHandler finishedTracking:nil];
    [NSThread sleepForTimeInterval:1.0];

    // If the response is null.
    anTest(@"AttributionHandler checkAttribution");
    anTest(@"Unable to open deep link");
    anTest(@"Open deep link");

    // Set package handler to respond with a valid attribution.

    NSString *deeplinkString = @"{\"deeplink\":\"wrongDeeplink://\"}";
    NSData *deeplinkData = [deeplinkString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *deeplinkDictionary = [ADJUtil buildJsonDict:deeplinkData];

    anNil(deeplinkDictionary);

    [activityHandler finishedTracking:deeplinkDictionary];

    [NSThread sleepForTimeInterval:1.0];

    // Check that it was unable to open the url.
    aError(@"Unable to open deep link (wrongDeeplink://)");

    // And it check the attribution.
    aTest(@"AttributionHandler checkAttribution");

    // TODO: Add test that opens url.

    // Checking the default values of the first session package
    // should only have one package.
    aiEquals(1, (int)[self.packageHandlerMock.packageQueue count]);

    ADJActivityPackage *activityPackage = (ADJActivityPackage *)self.packageHandlerMock.packageQueue[0];

    // Create activity package test.
    ADJPackageFields *fields = [ADJPackageFields fields];

    fields.hasDelegate = @"1";
    fields.environment = @"production";

    // Set first session.
    [self testPackageSession:activityPackage fields:fields sessionCount:@"1"];
}

- (void)testUpdateAttribution {
    // Reseting to make the test order independent.
    [self reset];

    // Create the config.
    ADJConfig *config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // Start the session.
    id<ADJActivityHandler> activityHandler =[ADJActivityHandler handlerWithConfig:config];

    [NSThread sleepForTimeInterval:2];

    // Test init values.
    [self checkInit:ADJEnvironmentSandbox logLevel:@"3"];

    // Test first session start.
    [self checkFirstSession];

    // Check if Attribution is not created with nil.
    ADJAttribution *nilAttribution = [[ADJAttribution alloc] initWithJsonDict:nil];

    aNil(nilAttribution);

    // Check it does not update a nil attribution.
    aFalse([activityHandler updateAttribution:nilAttribution]);

    // Create an empty attribution.
    NSMutableDictionary *emptyJsonDictionary = [[NSMutableDictionary alloc] init];
    ADJAttribution *emptyAttribution = [[ADJAttribution alloc] initWithJsonDict:emptyJsonDictionary];

    // Check that updates attribution.
    aTrue([activityHandler updateAttribution:emptyAttribution]);
    aDebug(@"Wrote Attribution: tt:(null) tn:(null) net:(null) cam:(null) adg:(null) cre:(null) cl:(null)");

    // Check that it did not launch a non existent delegate.
    // Not possible to test in iOs
    // [NSThread sleepForTimeInterval:1];
    // anTest(@"ADJDelegateTest adjustAttributionChanged");

    emptyAttribution = [[ADJAttribution alloc] initWithJsonDict:emptyJsonDictionary];

    // Check that it does not update the attribution.
    aFalse([activityHandler updateAttribution:emptyAttribution]);
    anDebug(@"Wrote Attribution");

    // End session.
    [activityHandler trackSubsessionEnd];
    [NSThread sleepForTimeInterval:2];

    [self checkEndSession];

    // Create the new config.
    config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // Set delegate to see attribution launched.
    ADJDelegateTest *delegateTests = [[ADJDelegateTest alloc] init];
    [config setDelegate:delegateTests];

    id<ADJActivityHandler> restartActivityHandler = [ADJActivityHandler handlerWithConfig:config];

    [NSThread sleepForTimeInterval:3];

    // Test init values.
    [self checkInit:ADJEnvironmentSandbox
           logLevel:@"3"
  readActivityState:@"ec:0 sc:1 ssc:1"
    readAttribution:@"tt:(null) tn:(null) net:(null) cam:(null) adg:(null) cre:(null) cl:(null)"];

    // Test second subsession.
    [self checkSubsession:1 subSessionCount:2 timerAlreadyStarted:NO];

    // Check that it does not update the attribution after the restart.
    aFalse([restartActivityHandler updateAttribution:emptyAttribution]);
    anDebug(@"Wrote Attribution");

    // New attribution.
    NSString *firstAttributionString = @"{ "
                                        "\"tracker_token\" : \"ttValue\" , "
                                        "\"tracker_name\"  : \"tnValue\" , "
                                        "\"network\"       : \"nValue\" , "
                                        "\"campaign\"      : \"cpValue\" , "
                                        "\"adgroup\"       : \"aValue\" , "
                                        "\"creative\"      : \"ctValue\" , "
                                        "\"click_label\"   : \"clValue\" }";

    NSData *firstAttributionData = [firstAttributionString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *firstAttributionDictionary = [ADJUtil buildJsonDict:firstAttributionData];

    anNil(firstAttributionDictionary);

    ADJAttribution *firstAttribution = [[ADJAttribution alloc] initWithJsonDict:firstAttributionDictionary];

    // Check that it updates.
    aTrue([restartActivityHandler updateAttribution:firstAttribution]);
    aDebug(@"Wrote Attribution: tt:ttValue tn:tnValue net:nValue cam:cpValue adg:aValue cre:ctValue cl:clValue");

    // Check that it launch the saved attribute.
    // Not possible to test in iOs.
    // [NSThread sleepForTimeInterval:2];
    // aTest(@"ADJDelegateTest adjustAttributionChanged, tt:null tn:null net:null cam:null adg:null cre:null cl:null");

    // Check that it does not update the attribution.
    aFalse([restartActivityHandler updateAttribution:firstAttribution]);
    anDebug(@"Wrote Attribution");

    // End session.
    [restartActivityHandler trackSubsessionEnd];
    [NSThread sleepForTimeInterval:2];

    [self checkEndSession];

    // Create the new config.
    config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // Set delegate to see attribution launched.
    [config setDelegate:delegateTests];

    id<ADJActivityHandler> secondRestartActivityHandler = [ADJActivityHandler handlerWithConfig:config];

    [NSThread sleepForTimeInterval:3];

    // Test init values.
    [self checkInit:ADJEnvironmentSandbox logLevel:@"3" readActivityState:@"ec:0 sc:1 ssc:2" readAttribution:@"tt:ttValue tn:tnValue net:nValue cam:cpValue adg:aValue cre:ctValue cl:clValue"];

    // Test third subsession.
    [self checkSubsession:1 subSessionCount:3 timerAlreadyStarted:NO];

    // Check that it does not update the attribution after the restart.
    aFalse([secondRestartActivityHandler updateAttribution:firstAttribution]);
    anDebug(@"Wrote Attribution");

    // New attribution.
    NSString *secondAttributionString = @"{ "
                                        "\"tracker_token\" : \"ttValue2\" , "
                                        "\"tracker_name\"  : \"tnValue2\" , "
                                        "\"network\"       : \"nValue2\" , "
                                        "\"campaign\"      : \"cpValue2\" , "
                                        "\"adgroup\"       : \"aValue2\" , "
                                        "\"creative\"      : \"ctValue2\" , "
                                        "\"click_label\"   : \"clValue2\" }";

    NSData *secondAttributionData = [secondAttributionString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *secondAttributionDictionary = [ADJUtil buildJsonDict:secondAttributionData];

    anNil(secondAttributionDictionary);

    ADJAttribution *secondAttribution = [[ADJAttribution alloc] initWithJsonDict:secondAttributionDictionary];

    // Check that it updates.
    aTrue([secondRestartActivityHandler updateAttribution:secondAttribution]);
    aDebug(@"Wrote Attribution: tt:ttValue2 tn:tnValue2 net:nValue2 cam:cpValue2 adg:aValue2 cre:ctValue2 cl:clValue2");

    // Check that it launch the saved attribute.
    // Not possible to test in iOs.
    // [NSThread sleepForTimeInterval:1];
    // aTest(@"onAttributionChanged: tt:ttValue2 tn:tnValue2 net:nValue2 cam:cpValue2 adg:aValue2 cre:ctValue2 cl:clValue2");

    // Check that it does not update the attribution.
    aFalse([secondRestartActivityHandler updateAttribution:secondAttribution]);
    anDebug(@"Wrote Attribution");
}

- (void)testOfflineMode {
    // Reseting to make the test order independent.
    [self reset];

    // Adjust the intervals for testing.
    [ADJAdjustFactory setSessionInterval:(2)]; // 2 seconds
    [ADJAdjustFactory setSubsessionInterval:(0.5)]; // 1/2 second

    // Create the config to start the session.
    ADJConfig *config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // Start activity handler with config.
    id<ADJActivityHandler> activityHandler = [ADJActivityHandler handlerWithConfig:config];

    // Put SDK offline.
    [activityHandler setOfflineMode:YES];

    [NSThread sleepForTimeInterval:3];

    // Check if message the disable of the SDK.
    aInfo(@"Pausing package and attribution handler to put in offline mode");

    // Test init values.
    [self checkInit:ADJEnvironmentSandbox logLevel:@"3"];

    // Test first session start.
    [self checkFirstSession:YES];

    // Test end session logs.
    [self checkEndSession];

    // Disable the SDK.
    [activityHandler setEnabled:NO];

    // Check that it is disabled.
    aFalse([activityHandler isEnabled]);

    // Writing activity state after disabling.
    aDebug(@"Wrote Activity state: ec:0 sc:1 ssc:1");

    // Check if message the disable of the SDK.
    aInfo(@"Pausing package handler and attribution handler to disable the SDK");

    [NSThread sleepForTimeInterval:1];

    // Test end session logs.
    [self checkEndSession];

    // Put SDK back online.
    [activityHandler setOfflineMode:NO];

    aInfo(@"Package and attribution handler remain paused because the SDK is disabled");

    [NSThread sleepForTimeInterval:1];

    // Doesn't pause if it was already paused.
    anTest(@"AttributionHandler pauseSending");
    anTest(@"PackageHandler pauseSending");

    // Try to do activities while SDK disabled.
    [activityHandler trackSubsessionStart];
    [activityHandler trackEvent:[ADJEvent eventWithEventToken:@"event1"]];

    [NSThread sleepForTimeInterval:3];

    // Check that timer was not executed.
    [self checkTimerIsFired:NO];

    // Check that it did not wrote activity state from new session or subsession.
    anDebug(@"Wrote Activity state");

    // Check that it did not add any package.
    anTest(@"PackageHandler addPackage");

    // Enable the SDK again.
    [activityHandler setEnabled:YES];

    // Check that is enabled.
    aTrue([activityHandler isEnabled]);

    [NSThread sleepForTimeInterval:1];

    // Check that it re-enabled.
    aInfo(@"Resuming package handler and attribution handler to enabled the SDK");

    // Test that is not paused anymore.
    [self checkNewSession:NO sessionCount:2 eventCount:0];
}

- (void)testGetAttribution {
    // Reseting to make the test order independent.
    [self reset];

    // Adjust the intervals for testing.
    [ADJAdjustFactory setTimerStart:0.5]; // 0.5 second
    [ADJAdjustFactory setSessionInterval:(4)]; // 4 second

    // Create the config to start the session.
    ADJConfig *config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // Set delegate.
    ADJDelegateTest *delegateTests = [[ADJDelegateTest alloc] init];
    [config setDelegate:delegateTests];

    // Create handler and start the first session.
    id<ADJActivityHandler> activityHandler = [ADJActivityHandler handlerWithConfig:config];

    // It's necessary to sleep the activity for a while after each handler call
    // to let the internal queue act.
    [NSThread sleepForTimeInterval:3.0];

    // Test init values.
    [self checkInit:ADJEnvironmentSandbox logLevel:@"3"];

    /***
     * // If it' a new session.
     * if (self.activityState.subsessionCount <= 1) {
     *     return;
     * }
     *
     * // If there is already an attribution saved and there was no attribution being asked.
     * if (self.attribution != nil && !self.activityState.askingAttribution) {
     *     return;
     * }
     *
     * [[self getAttributionHandler] getAttribution];
     */

    // Subsession count is 1
    // Attribution is null,
    // AskingAttribution is false by default,
    // -> Not called

    // Test first session start.
    [self checkFirstSession];

    // Test that get attribution wasn't called.
    anTest(@"AttributionHandler getAttribution");

    // Subsession count increased to 2
    // Attribution is still null,
    // AskingAttribution is still false,
    // -> Called

    // Trigger a new sub session.
    [activityHandler trackSubsessionStart];
    [NSThread sleepForTimeInterval:2.0];

    [self checkSubsession:1 subSessionCount:2 timerAlreadyStarted:YES getAttributionIsCalled:YES];

    // Subsession count increased to 3
    // Attribution is still null,
    // AskingAttribution is set to true,
    // -> Called

    // Set asking attribution.
    [activityHandler setAskingAttribution:YES];
    aDebug(@"Wrote Activity state: ec:0 sc:1 ssc:2");

    // Trigger a new session.
    [activityHandler trackSubsessionStart];
    [NSThread sleepForTimeInterval:2.0];

    [self checkSubsession:1 subSessionCount:3 timerAlreadyStarted:YES getAttributionIsCalled:YES];

    // Subsession is reset to 1 with new session
    // Attribution is still null,
    // AskingAttribution is set to true,
    // -> Not called

    [NSThread sleepForTimeInterval:3.0]; // 5 seconds = 2 + 3
    [activityHandler trackSubsessionStart];
    [NSThread sleepForTimeInterval:2.0];

    [self checkSubsession:2 subSessionCount:1 timerAlreadyStarted:YES getAttributionIsCalled:NO];

    // Subsession count increased to 2
    // Attribution is set,
    // AskingAttribution is set to true,
    // -> Called

    NSString *attributionString =   @"{ "
                                    "\"tracker_token\" : \"ttValue\" , "
                                    "\"tracker_name\"  : \"tnValue\" , "
                                    "\"network\"       : \"nValue\" , "
                                    "\"campaign\"      : \"cpValue\" , "
                                    "\"adgroup\"       : \"aValue\" , "
                                    "\"creative\"      : \"ctValue\" , "
                                    "\"click_label\"   : \"clValue\" }";

    NSData *attributionData = [attributionString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *attributionDictionary = [ADJUtil buildJsonDict:attributionData];

    anNil(attributionDictionary);

    ADJAttribution *attribution = [[ADJAttribution alloc] initWithJsonDict:attributionDictionary];

    // Update the attribution.
    [activityHandler updateAttribution:attribution];

    // Attribution was updated.
    aDebug(@"Wrote Attribution: tt:ttValue tn:tnValue net:nValue cam:cpValue adg:aValue cre:ctValue cl:clValue");

    // Trigger a new sub session.
    [activityHandler trackSubsessionStart];
    [NSThread sleepForTimeInterval:2.0];

    [self checkSubsession:2 subSessionCount:2 timerAlreadyStarted:YES getAttributionIsCalled:YES];

    // Subsession count is reset to 1
    // Attribution is set,
    // AskingAttribution is set to true,
    // -> Not called

    [NSThread sleepForTimeInterval:3.0]; // 5 seconds = 2 + 3
    [activityHandler trackSubsessionStart];
    [NSThread sleepForTimeInterval:2.0];

    [self checkSubsession:3 subSessionCount:1 timerAlreadyStarted:YES getAttributionIsCalled:NO];

    // Subsession increased to 2
    // Attribution is set,
    // AskingAttribution is set to false
    // -> Not called

    [activityHandler setAskingAttribution:NO];
    aDebug(@"Wrote Activity state: ec:0 sc:3 ssc:1");

    // Trigger a new sub session.
    [activityHandler trackSubsessionStart];
    [NSThread sleepForTimeInterval:2.0];

    [self checkSubsession:3 subSessionCount:2 timerAlreadyStarted:YES getAttributionIsCalled:NO];

    // Subsession is reset to 1
    // Attribution is set,
    // AskingAttribution is set to false
    // -> Not called

    [NSThread sleepForTimeInterval:3.0]; // 5 seconds = 2 + 3
    [activityHandler trackSubsessionStart];
    [NSThread sleepForTimeInterval:2.0];

    [self checkSubsession:4 subSessionCount:1 timerAlreadyStarted:YES getAttributionIsCalled:NO];
}

- (void)testTimer {
    // Reseting to make the test order independent.
    [self reset];

    // Change the timer defaults.
    [ADJAdjustFactory setTimerInterval:4];
    [ADJAdjustFactory setTimerStart:0];

    // Create the config to start the session.
    ADJConfig *config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // Create handler and start the first session.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    id<ADJActivityHandler> activityHandler = [ADJActivityHandler handlerWithConfig:config];
#pragma clang diagnostic pop

    // It's necessary to sleep the activity for a while after each handler call
    // to let the internal queue act.
    [NSThread sleepForTimeInterval:2.0];

    // Test init values
    [self checkInit:ADJEnvironmentSandbox logLevel:@"3"];

    // Test first session start.
    [self checkFirstSession];

    // Wait enough to fire the first cycle.
    [NSThread sleepForTimeInterval:3.0];

    [self checkTimerIsFired:YES];

    // End subsession to stop timer.
    // [activityHandler trackSubsessionEnd];

    // Wait enough for a new cycle.
    // [NSThread sleepForTimeInterval:6.0];

    // [activityHandler trackSubsessionStart];

    // [NSThread sleepForTimeInterval:1.0];

    // [self checkTimerIsFired:NO];
}

- (void)checkInit:(NSString *)environment
         logLevel:(NSString *)logLevel {
    [self checkInit:environment logLevel:logLevel readActivityState:nil readAttribution:nil];
}

- (void)checkInit:(NSString *)environment
         logLevel:(NSString *)logLevel
readActivityState:(NSString *)readActivityState
  readAttribution:(NSString *)readAttribution {
    // Check environment level.
    if ([environment isEqualToString:ADJEnvironmentSandbox]) {
        aAssert(@"SANDBOX: Adjust is running in Sandbox mode. Use this setting for testing. Don't forget to set the environment to `production` before publishing");
    } else if ([environment isEqualToString:ADJEnvironmentProduction]) {
        aAssert(@"PRODUCTION: Adjust is running in Production mode. Use this setting only for the build that you want to publish. Set the environment to `sandbox` if you want to test your app!");
    } else {
        aFail();
    }

    // Check log level.
    aTest([@"ADJLogger setLogLevel: " stringByAppendingString:logLevel]);

    // Check read files.
    [self checkReadFiles:readActivityState readAttribution:readAttribution];
}

- (void)checkReadFiles:(NSString *)readActivityState
       readAttribution:(NSString *)readAttribution {
    if (readAttribution == nil) {
        aVerbose(@"Attribution file not found");
    } else {
        aDebug([@"Read Attribution: " stringByAppendingString:readAttribution]);
    }

    if (readActivityState == nil) {
        aVerbose(@"Activity state file not found");
    } else {
        aDebug([@"Read Activity state: " stringByAppendingString:readActivityState]);
    }
}

- (void)checkFirstSession:(BOOL)paused {
    // Test if package handler started paused.
    if (paused) {
        aTest(@"PackageHandler initWithActivityHandler, paused: 1");
    } else {
        aTest(@"PackageHandler initWithActivityHandler, paused: 0");
    }

    [self checkNewSession:paused sessionCount:1 eventCount:0 timerAlreadyStarted:NO];
}

- (void)checkFirstSession {
    [self checkFirstSession:NO];
}

- (void)checkNewSession:(BOOL)paused
           sessionCount:(int)sessionCount
             eventCount:(int)eventCount {
    [self checkNewSession:paused sessionCount:sessionCount eventCount:eventCount timerAlreadyStarted:NO];
}
- (void)checkNewSession:(BOOL)paused
           sessionCount:(int)sessionCount
             eventCount:(int)eventCount
    timerAlreadyStarted:(BOOL)timerAlreadyStarted {
    // When a session package is being sent the attribution handler should resume sending.
    if (paused) {
        aTest(@"AttributionHandler pauseSending");
    } else {
        aTest(@"AttributionHandler resumeSending");
    }

    // When a session package is being sent the package handler should resume sending.
    if (paused) {
        aTest(@"PackageHandler pauseSending");
    } else {
        aTest(@"PackageHandler resumeSending");
    }

    // If the package was build, it was sent to the Package Handler.
    aTest(@"PackageHandler addPackage");

    // After adding, the activity handler ping the Package handler to send the package.
    aTest(@"PackageHandler sendFirstPackage");

    // After sending a package saves the activity state.
    NSString *aStateWrote = [NSString stringWithFormat:@"Wrote Activity state: ec:%d sc:%d ssc:1",
                             eventCount, sessionCount];
    aDebug(aStateWrote);

    [self checkTimerIsFired:!(paused || timerAlreadyStarted)];
}

- (void)checkSubsession:(int)sessionCount
       subSessionCount:(int)subsessionCount
    timerAlreadyStarted:(BOOL)timerAlreadyStarted
 getAttributionIsCalled:(BOOL)getAttributionIsCalled {
    [self checkSubsession:sessionCount subSessionCount:subsessionCount];

    if (getAttributionIsCalled) {
        aTest(@"AttributionHandler getAttribution");
    } else {
        anTest(@"AttributionHandler getAttribution");
    }

    [self checkTimerIsFired:!timerAlreadyStarted];
}

- (void)checkSubsession:(int)sessionCount
        subSessionCount:(int)subsessionCount
    timerAlreadyStarted:(BOOL)timerAlreadyStarted {
    [self checkSubsession:sessionCount subSessionCount:subsessionCount];
    [self checkTimerIsFired:!timerAlreadyStarted];
}

- (void)checkSubsession:(int)sessionCount
        subSessionCount:(int)subsessionCount {
    // Test the new sub session.
    aTest(@"PackageHandler resumeSending");

    // Save activity state.
    NSString *aStateWrote = [NSString stringWithFormat:@"Wrote Activity state: ec:0 sc:%d ssc:%d",
                            sessionCount, subsessionCount];
    aDebug(aStateWrote);
    // aDebug(@"Wrote Activity state: ec:0 sc:1 ssc:2");

    if (subsessionCount > 1) {
        // Test the subsession message.
        NSString *subsessionStarted = [NSString stringWithFormat:@"Started subsession %d of session %d",
                                       subsessionCount, sessionCount];
        aInfo(subsessionStarted);
    } else {
        // Test the subsession message.
        anInfo(@"Started subsession ");
    }
}

- (void)checkEndSession {
    aTest(@"PackageHandler pauseSending");
    aTest(@"AttributionHandler pauseSending");
    aDebug(@"Wrote Activity state:");
}

- (void)checkTimerIsFired:(BOOL)timerFired {
    if(timerFired) {
        aDebug(@"Session timer fired");
    } else {
        anDebug(@"Session timer fired");
    }
}

@end
