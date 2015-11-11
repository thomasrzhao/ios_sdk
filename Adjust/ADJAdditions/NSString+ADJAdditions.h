//
//  NSString+ADJAdditions.h
//  adjust GmbH
//
//  Created by Christian Wellenbrock on 23/07/12.
//  Copyright (c) 2012-2015 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSString(ADJAdditions)

- (NSString *)adjTrim;
- (NSString *)adjMd5;
- (NSString *)adjSha1;
- (NSString *)adjUrlEncode;
- (NSString *)adjRemoveColons;

+ (NSString *)adjJoin:(NSString *)strings, ...;
+ (BOOL) adjIsEqual:(NSString *)first toString:(NSString *)second;

@end
