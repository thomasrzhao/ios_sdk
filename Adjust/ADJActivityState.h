//
//  ADJActivityState.h
//  adjust GmbH
//
//  Created by Christian Wellenbrock on 02/07/2013.
//  Copyright (c) 2013-2015 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJActivityState : NSObject <NSCoding, NSCopying>

// Persistent data
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL askingAttribution;

// Global counters
@property (nonatomic, assign) int eventCount;
@property (nonatomic, assign) int sessionCount;

// Session attributes
@property (nonatomic, assign) int subsessionCount;
@property (nonatomic, assign) double timeSpent;
@property (nonatomic, assign) double sessionLength; // all durations in seconds
@property (nonatomic, assign) double lastActivity;  // all times in seconds since 1970

// Last ten transaction identifiers
@property (nonatomic, retain) NSMutableArray *transactionIds;

// Not persisted, only injected
@property (nonatomic, assign) double lastInterval;

- (void)resetSessionAttributes:(double)now;

// Transaction ID management
- (void)addTransactionId:(NSString *)transactionId;
- (BOOL)findTransactionId:(NSString *)transactionId;

@end
