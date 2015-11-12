//
//  ADJPackageFields.m
//  adjust GmbH
//
//  Created by Pedro Filipe on 15/05/15.
//  Copyright (c) 2015 adjust GmbH. All rights reserved.
//

#import "ADJPackageFields.h"

@implementation ADJPackageFields

- (id)init {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    // Default values.
    self.appToken       = @"123456789012";
    self.clientSdk      = @"ios4.4.1";
    self.suffix         = @"";
    self.environment    = @"sandbox";

    return self;
}

+ (ADJPackageFields *)fields {
    return [[ADJPackageFields alloc] init];
}

/*
+ (ADJPackageFields *)fieldsWithPackage:(ADJActivityPackage *)activityPackage {
    return [[ADJPackageFields alloc] initWithPackage:activityPackage];
}

- (id)initWithPackage:(ADJActivityPackage *)activityPackage {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    self.activityPackage = activityPackage;

    return self;
}
*/

@end
