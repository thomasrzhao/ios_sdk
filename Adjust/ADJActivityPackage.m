//
//  ADJActivityPackage.m
//  adjust GmbH
//
//  Created by Christian Wellenbrock on 03/07/2013.
//  Copyright (c) 2013-2015 adjust GmbH. All rights reserved.
//

#import "ADJActivityKind.h"
#import "ADJActivityPackage.h"

@implementation ADJActivityPackage

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];

    if (self == nil) {
        return self;
    }

    self.path               = [decoder decodeObjectForKey:@"path"];
    self.clientSdk          = [decoder decodeObjectForKey:@"clientSdk"];
    self.parameters         = [decoder decodeObjectForKey:@"parameters"];
    NSString *kindString    = [decoder decodeObjectForKey:@"kind"];
    self.suffix             = [decoder decodeObjectForKey:@"suffix"];

    self.activityKind = [ADJActivityKindUtil activityKindFromString:kindString];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    NSString *kindString = [ADJActivityKindUtil activityKindToString:self.activityKind];

    [encoder encodeObject:self.path         forKey:@"path"];
    [encoder encodeObject:self.clientSdk    forKey:@"clientSdk"];
    [encoder encodeObject:self.parameters   forKey:@"parameters"];
    [encoder encodeObject:kindString        forKey:@"kind"];
    [encoder encodeObject:self.suffix       forKey:@"suffix"];
}

#pragma mark - Private methods

- (NSString *)description {
    return [NSString stringWithFormat:@"%@%@",
            [ADJActivityKindUtil activityKindToString:self.activityKind],
            self.suffix];
}

#pragma mark - Public methods

- (NSString *)extendedString {
    NSMutableString *builder = [NSMutableString string];
    [builder appendFormat:@"Path:      %@\n", self.path];
    [builder appendFormat:@"ClientSdk: %@\n", self.clientSdk];

    if (self.parameters != nil) {
        NSArray *sortedKeys = [[self.parameters allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
        NSUInteger keyCount = [sortedKeys count];
        [builder appendFormat:@"Parameters:"];

        for (int i = 0; i < keyCount; i++) {
            NSString *key = (NSString *)[sortedKeys objectAtIndex:i];
            NSString *value = [self.parameters objectForKey:key];

            [builder appendFormat:@"\n\t\t%-22s %@", [key UTF8String], value];
        }
    }

    return builder;
}

- (NSString *)successMessage {
    return [NSString stringWithFormat:@"Tracked %@%@",
            [ADJActivityKindUtil activityKindToString:self.activityKind],
            self.suffix];
}

- (NSString *)failureMessage {
    return [NSString stringWithFormat:@"Failed to track %@%@",
            [ADJActivityKindUtil activityKindToString:self.activityKind],
            self.suffix];
}

@end
