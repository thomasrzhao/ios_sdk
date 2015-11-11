//
//  ADJLogger.h
//  adjust GmbH
//
//  Created by Christian Wellenbrock on 15/11/2012.
//  Copyright (c) 2012-2015 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ADJLogLevelVerbose = 1,
    ADJLogLevelDebug   = 2,
    ADJLogLevelInfo    = 3,
    ADJLogLevelWarn    = 4,
    ADJLogLevelError   = 5,
    ADJLogLevelAssert  = 6
} ADJLogLevel;

// A simple logger with multiple log levels.
@protocol ADJLogger

- (void)verbose:(NSString *)message, ...;
- (void)debug:  (NSString *)message, ...;
- (void)info:   (NSString *)message, ...;
- (void)warn:   (NSString *)message, ...;
- (void)error:  (NSString *)message, ...;
- (void)assert: (NSString *)message, ...;

- (void)setLogLevel:(ADJLogLevel)logLevel;

@end

@interface ADJLogger : NSObject <ADJLogger>

+ (ADJLogLevel)LogLevelFromString:(NSString *)logLevelString;

@end
