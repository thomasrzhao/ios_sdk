//
//  ADJPackageHandlerMock.h
//  adjust GmbH
//
//  Created by Pedro Filipe on 10/02/14.
//  Copyright (c) 2014-2015 adjust GmbH. All rights reserved.
//

#import "ADJPackageHandler.h"

@interface ADJPackageHandlerMock : NSObject <ADJPackageHandler>

@property (nonatomic, strong) NSDictionary *jsonDict;
@property (nonatomic, strong) NSMutableArray *packageQueue;
@property (nonatomic, strong) ADJActivityPackage *activityPackage;

@end
