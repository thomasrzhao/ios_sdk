//
//  ADJLogger.m
//  adjust GmbH
//
//  Created by Christian Wellenbrock on 15/11/2012.
//  Copyright (c) 2012-2015 adjust GmbH. All rights reserved.
//

#import "ADJLogger.h"

static NSString * const kLogTag = @"Adjust";

@interface ADJLogger()

@property (nonatomic, assign) ADJLogLevel loglevel;

@end

@implementation ADJLogger

#pragma mark - Private methods

// Private implementation.
- (void)logLevel:(NSString *)logLevel format:(NSString *)format parameters:(va_list)parameters {
    NSString *string = [[NSString alloc] initWithFormat:format arguments:parameters];
    va_end(parameters);

    NSArray *lines = [string componentsSeparatedByString:@"\n"];

    for (NSString *line in lines) {
        NSLog(@"\t[%@]%@: %@", kLogTag, logLevel, line);
    }
}

#pragma mark - Public methods

- (void)setLogLevel:(ADJLogLevel)logLevel {
    self.loglevel = logLevel;
}

- (void)verbose:(NSString *)format, ... {
    if (self.loglevel > ADJLogLevelVerbose) {
        return;
    }

    va_list parameters; va_start(parameters, format);
    [self logLevel:@"v" format:format parameters:parameters];
}

- (void)debug:(NSString *)format, ... {
    if (self.loglevel > ADJLogLevelDebug) {
        return;
    }

    va_list parameters; va_start(parameters, format);
    [self logLevel:@"d" format:format parameters:parameters];
}

- (void)info:(NSString *)format, ... {
    if (self.loglevel > ADJLogLevelInfo) {
        return;
    }

    va_list parameters; va_start(parameters, format);
    [self logLevel:@"i" format:format parameters:parameters];
}

- (void)warn:(NSString *)format, ... {
    if (self.loglevel > ADJLogLevelWarn) {
        return;
    }

    va_list parameters; va_start(parameters, format);
    [self logLevel:@"w" format:format parameters:parameters];
}

- (void)error:(NSString *)format, ... {
    if (self.loglevel > ADJLogLevelError) {
        return;
    }

    va_list parameters; va_start(parameters, format);
    [self logLevel:@"e" format:format parameters:parameters];
}

- (void)assert:(NSString *)format, ... {
    if (self.loglevel > ADJLogLevelAssert) {
        return;
    }

    va_list parameters; va_start(parameters, format);
    [self logLevel:@"a" format:format parameters:parameters];
}

+ (ADJLogLevel)LogLevelFromString:(NSString *)logLevelString {
    if ([logLevelString isEqualToString:@"verbose"]) {
        return ADJLogLevelVerbose;
    }

    if ([logLevelString isEqualToString:@"debug"]) {
        return ADJLogLevelDebug;
    }

    if ([logLevelString isEqualToString:@"info"]) {
        return ADJLogLevelInfo;
    }

    if ([logLevelString isEqualToString:@"warn"]) {
        return ADJLogLevelWarn;
    }

    if ([logLevelString isEqualToString:@"error"]) {
        return ADJLogLevelError;
    }

    if ([logLevelString isEqualToString:@"assert"]) {
        return ADJLogLevelAssert;
    }

    // Default value if string does not match.
    return ADJLogLevelInfo;
}

@end
