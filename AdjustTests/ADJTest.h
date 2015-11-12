//
//  ADJTest.h
//  adjust GmbH
//
//  Created by Pedro Filipe on 15/05/15.
//  Copyright (c) 2015 adjust GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>

#import "ADJLoggerMock.h"

// Assert level
#define aLevel(message, logLevel) \
    XCTAssert([self.loggerMock \
            deleteUntil:logLevel \
            beginsWith:message], \
          @"%@", self.loggerMock)

// Assert test log
#define aTest(message) aLevel(message, ADJLogLevelTest)

// Assert verbose log
#define aVerbose(message) aLevel(message, ADJLogLevelVerbose)

// Assert debug log
#define aDebug(message) aLevel(message, ADJLogLevelDebug)

// Assert info log
#define aInfo(message) aLevel(message, ADJLogLevelInfo)

// Assert warn log
#define aWarn(message) aLevel(message, ADJLogLevelWarn)

// Assert error log
#define aError(message) aLevel(message, ADJLogLevelError)

// Assert assert log
#define aAssert(message) aLevel(message, ADJLogLevelAssert)

// Assert not level
#define anLevel(message, logLevel) \
    XCTAssertFalse([self.loggerMock \
            deleteUntil:logLevel \
            beginsWith:message], \
        @"%@", self.loggerMock)

// Assert not test log
#define anTest(message) anLevel(message, ADJLogLevelTest)

// Assert not verbose log
#define anVerbose(message) anLevel(message, ADJLogLevelVerbose)

// Assert not debug log
#define anDebug(message) anLevel(message, ADJLogLevelDebug)

// Assert not info log
#define anInfo(message) anLevel(message, ADJLogLevelInfo)

// Assert not warn log
#define anWarn(message) anLevel(message, ADJLogLevelWarn)

// Assert not assert log
#define anAssert(message) anLevel(message, ADJLogLevelAssert)

// Assert fail
#define aFail() \
    XCTFail(@"l:%@", self.loggerMock)

// Assert false
#define aFalse(value) \
    XCTAssertFalse(value, @"v:%d, %@", value, self.loggerMock)

// Assert log true
#define alTrue(value, log) \
    XCTAssert(value, @"v:%d, %@", value, log)

// Assert true
#define aTrue(value) \
    alTrue(value, self.loggerMock)

// Assert equals string log
#define aslEquals(field, value, log) \
    XCTAssert([field isEqualToString:value] || (field == nil && value == nil), @"f:%@, v:%@, l:%@", field, value, log)

// Assert equals integer log
#define ailEquals(field, value, log) \
    XCTAssertEqual(field, value, @"f:%d, v:%d, l:%@", field, value, log)

// Assert equals log
#define alEquals(field, value, log) \
    XCTAssertEqual(field, value, @"f:%@, v:%@, l:%@", field, value, log)

// Assert not nil log
#define anlNil(field, log) \
    XCTAssertNotNil(field, @"f:%@, l:%@", field, log)

// Assert nil log
#define alNil(field, log) \
    XCTAssertNil(field, @"f:%@, l:%@", field, log)

// Assert equals integer
#define aiEquals(field, value) \
    ailEquals(field, value, self.loggerMock)

// Assert not nill
#define anNil(field) \
    anlNil(field, self.loggerMock)

// Assert nil
#define aNil(field) \
    alNil(field, self.loggerMock)

@interface ADJTest : XCTestCase

@property (atomic, strong) ADJLoggerMock *loggerMock;

@end
