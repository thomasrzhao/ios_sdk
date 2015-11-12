//
//  ADJTestActivityPackage.m
//  adjust GmbH
//
//  Created by Pedro Filipe on 15/05/15.
//  Copyright (c) 2015 adjust GmbH. All rights reserved.
//

#import "ADJUtil.h"
#import "ADJActivityKind.h"
#import "ADJTestActivityPackage.h"

// Assert package string equals
#define apsEquals(field, value) \
    aslEquals(field, value, package.extendedString)

// Assert package integer equals
#define apiEquals(field, value) \
    ailEquals(field, value, package.extendedString)

// Assert package equals
#define apEquals(field, value) \
    alEquals(field, value, package.extendedString)

// Assert package string parameter equals
#define apspEquals(parameterName, value) \
    apsEquals((NSString *)package.parameters[parameterName], value)

// Assert package integer parameter equals
#define apipEquals(parameterName, value) \
    apspEquals(parameterName, [NSString stringWithFormat:@"%d",value])

// Assert package parameter not nil
#define appnNil(parameterName) \
    anlNil((NSString *)package.parameters[parameterName], package.extendedString)

// Assert package paramenter nil
#define appNil(parameterName) \
    alNil((NSString *)package.parameters[parameterName], package.extendedString)

@interface ADJTestActivityPackage()

@end

@implementation ADJTestActivityPackage

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)resetAttributes {
}

- (void)testPackageSession:(ADJActivityPackage *)package
                    fields:(ADJPackageFields *)fields
              sessionCount:(NSString *)sessionCount {
    // Set the session count.
    fields.sessionCount = sessionCount;

    // Test default package attributes.
    [self testDefaultAttributes:package
                         fields:fields
                           path:@"/session"
                   activityKind:ADJActivityKindSession
             activityKindString:@"session"];

    // Check default parameters.
    [self testDefaultParameters:package
                         fields:fields];

    // Session parameters

    // last_interval
    if ([@"1" isEqualToString:fields.sessionCount]) {
        appNil(@"last_interval");
    } else {
        appnNil(@"last_interval");
    }

    // default_tracker
    apspEquals(@"default_tracker", fields.defaultTracker);
}

- (void)testEventSession:(ADJActivityPackage *)package
                  fields:(ADJPackageFields *)fields
              eventToken:(NSString *)eventToken {
    // Test default package attributes.
    [self testDefaultAttributes:package
                         fields:fields
                           path:@"/event"
                   activityKind:ADJActivityKindEvent
             activityKindString:@"event"];

    // Check default parameters.
    [self testDefaultParameters:package
                         fields:fields];

    // Event parameters

    // event_count
    if (fields.eventCount == nil) {
        appnNil(@"event_count");
    } else {
        apspEquals(@"event_count", fields.eventCount);
    }

    // event_token
    apspEquals(@"event_token", eventToken);

    // Revenue and currency must come together.
    if (package.parameters[@"revenue"] != nil && package.parameters[@"currency"] == nil) {
        XCTFail(@"%@",package.extendedString);
    }

    if (package.parameters[@"revenue"] == nil && package.parameters[@"currency"] != nil) {
        XCTFail(@"%@",package.extendedString);
    }

    // revenue
    apspEquals(@"revenue", fields.revenue);

    // currency
    apspEquals(@"currency", fields.currency);

    // callback_params
    [self assertJsonParameters:package parameterName:@"callback_params" value:fields.callbackParameters];

    // partner_params
    [self assertJsonParameters:package parameterName:@"partner_params" value:fields.partnerParameters];
}

- (void)testClickPackage:(ADJActivityPackage *)package
                  fields:(ADJPackageFields *)fields
                  source:(NSString *)source {
    // Test default package attributes.
    [self testDefaultAttributes:package
                         fields:fields
                           path:@"/sdk_click"
                   activityKind:ADJActivityKindClick
             activityKindString:@"click"];

    // Check ids parameters.
    [self testIdsParameters:package fields:fields];

    // Click parameters

    // source
    apspEquals(@"source", source);

    // params
    [self assertJsonParameters:package parameterName:@"params" value:fields.deepLinkParameters];

    // click_time
    // TODO: Test click_time
    if (fields.iadTime == nil) {
        appnNil(@"click_time");
    } else {
        apspEquals(@"click_time", fields.iadTime);
    }

    // purchase_time
    apspEquals(@"purchase_time", fields.purchaseTime);

    // attributions
    if (fields.attribution == nil) {
        // tracker
        appNil(@"tracker");

        // campaign
        appNil(@"campaign");

        // adgroup
        appNil(@"adgroup");

        // creative
        appNil(@"creative");
    } else {
        // tracker
        apspEquals(@"tracker", fields.attribution.trackerName);

        // campaign
        apspEquals(@"campaign", fields.attribution.campaign);

        // adgroup
        apspEquals(@"adgroup", fields.attribution.adgroup);

        // creative
        apspEquals(@"creative", fields.attribution.creative);
    }
}

- (void)testAttributionPackage:(ADJActivityPackage *)package
                  fields:(ADJPackageFields *)fields {
    // Test default package attributes.
    [self testDefaultAttributes:package
                         fields:fields
                           path:@"/attribution"
                   activityKind:ADJActivityKindAttribution
             activityKindString:@"attribution"];

    // Check ids parameters
    [self testIdsParameters:package fields:fields];
}

- (void)testDefaultAttributes:(ADJActivityPackage *)package
                       fields:(ADJPackageFields *)fields
                         path:(NSString *)path
                 activityKind:(ADJActivityKind)activityKind
           activityKindString:(NSString *)activityKindString {
    // Check the Sdk version is being tested.
    apsEquals(package.clientSdk, fields.clientSdk);

    // Check the path.
    apsEquals(package.path, path);

    // Test activity kind.

    // Check the activity kind.
    apiEquals(package.activityKind, activityKind);

    // The conversion from activity kind to String.
    apsEquals([ADJActivityKindUtil activityKindToString:package.activityKind], activityKindString);

    // The conversion from String to activity kind.
    apiEquals(package.activityKind, [ADJActivityKindUtil activityKindFromString:activityKindString]);

    // Test suffix.
    apsEquals(package.suffix, fields.suffix);
}

- (void)testIdsParameters:(ADJActivityPackage *)package
                   fields:(ADJPackageFields *)fields {
    [self testDeviceInfoIds:package fields:fields];
    [self testConfig:package fields:fields];

    // created_at
    appnNil(@"created_at");

}

- (void)testDefaultParameters:(ADJActivityPackage *)package
                       fields:(ADJPackageFields *)fields {
    [self testDeviceInfo:package fields:fields];
    [self testConfig:package fields:fields];
    [self testActivityState:package fields:fields];

    // created_at
    appnNil(@"created_at");
}

- (void)testDeviceInfoIds:(ADJActivityPackage *)package
                   fields:(ADJPackageFields *)fields {
    // mac_sha1
    appnNil(@"mac_sha1");

    // idfa
    appnNil(@"idfa");

    // idfv
    appnNil(@"idfv");

    // mac_md5
    // Can't test in simulator.
}

- (void)testDeviceInfo:(ADJActivityPackage *)package
                fields:(ADJPackageFields *)fields {
    [self testDeviceInfoIds:package fields:fields];

    // fb_id
    // appnNil(@"fb_id");

    // tracking_enabled
    appnNil(@"tracking_enabled");

    // push_token
    apspEquals(@"push_token", fields.pushToken);

    // bundle_id
    // appnNil(@"bundle_id");

    // app_version
    // appnNil(@"app_version");

    // device_type
    appnNil(@"device_type");

    // device_name
    appnNil(@"device_name");

    // os_name
    appnNil(@"os_name");

    // os_version
    appnNil(@"os_version");

    // language
    appnNil(@"language");

    // country
    appnNil(@"country");
}

- (void)testConfig:(ADJActivityPackage *)package
            fields:(ADJPackageFields *)fields {
    // app_token
    apspEquals(@"app_token", fields.appToken);

    // environment
    apspEquals(@"environment", fields.environment);

    // needs_attribution_data
    if (fields.hasDelegate == nil) {
        appnNil(@"needs_attribution_data");
    } else {
        apspEquals(@"needs_attribution_data", fields.hasDelegate);
    }
}

- (void)testActivityState:(ADJActivityPackage *)package
                   fields:(ADJPackageFields *)fields {
    // session_count
    if (fields.sessionCount == nil) {
        appnNil(@"session_count");
    } else {
        apspEquals(@"session_count", fields.sessionCount);
    }

    // first session
    if ([@"1" isEqualToString:fields.sessionCount]) {
        // subsession_count
        appNil(@"subsession_count");

        // session_length
        appNil(@"session_length");

        // time_spent
        appNil(@"time_spent");
    } else {
        // subsession_count
        if (fields.subSessionCount == nil) {
            appnNil(@"subsession_count");
        } else {
            apspEquals(@"subsession_count", fields.subSessionCount);
        }

        // session_length
        appnNil(@"session_length");

        // time_spent
        appnNil(@"time_spent");
    }

    // ios_uuid
    appnNil(@"ios_uuid");
}

- (BOOL)assertJsonParameters:(ADJActivityPackage *)package
               parameterName:(NSString *)parameterName
                       value:(NSString *)value {
    NSString *parameterValue = (NSString *)package.parameters[parameterName];

    if (parameterValue == nil) {
        return value == nil;
    }

    // Value not nil
    anlNil(value, package.extendedString);

    NSData *parameterData = [parameterValue dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameterDictionary = [ADJUtil buildJsonDict:parameterData];

    // Check parameter parses from Json string.
    anlNil(parameterDictionary, package.extendedString);

    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *valueDictionary = [ADJUtil buildJsonDict:valueData];

    // Check value parses from Json string.
    anlNil(valueDictionary, package.extendedString);

    // Check if the json is equal.
    alTrue([valueDictionary isEqualToDictionary:parameterDictionary], package.extendedString);
}

@end
