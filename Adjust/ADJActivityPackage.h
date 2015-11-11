//
//  ADJActivityPackage.h
//  adjust GmbH
//
//  Created by Christian Wellenbrock on 03/07/2013.
//  Copyright (c) 2013-2015 adjust GmbH. All rights reserved.
//

#import "ADJActivityKind.h"

@interface ADJActivityPackage : NSObject <NSCoding>

// Data
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *clientSdk;
@property (nonatomic, retain) NSDictionary *parameters;

// Logs
@property (nonatomic, copy) NSString *suffix;
@property (nonatomic, assign) ADJActivityKind activityKind;

- (NSString *)extendedString;
- (NSString *)successMessage;
- (NSString *)failureMessage;

@end
