//
//  ADJTestsUtil.h
//  adjust GmbH
//
//  Created by Pedro Filipe on 12/02/14.
//  Copyright (c) 2014-2015 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Adjust.h"
#import "ADJLoggerMock.h"
#import "ADJActivityPackage.h"

@interface ADJTestsUtil : NSObject <AdjustDelegate>

- (id)initWithLoggerMock:(ADJLoggerMock *)loggerMock;

+ (NSString *)getFilename:(NSString *)filename;
+ (ADJActivityPackage *)getUnknowPackage:(NSString*)suffix;
+ (ADJActivityPackage *)getClickPackage:(NSString*)suffix;
+ (BOOL)deleteFile:(NSString *)filename logger:(ADJLoggerMock *)loggerMock;

@end
