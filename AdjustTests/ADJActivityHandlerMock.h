//
//  ADJActivityHandlerMock.h
//  adjust GmbH
//
//  Created by Pedro Filipe on 11/02/14.
//  Copyright (c) 2014-2015 adjust GmbH. All rights reserved.
//

#import "ADJAttribution.h"
#import "ADJActivityHandler.h"

@interface ADJActivityHandlerMock : NSObject <ADJActivityHandler>

@property (nonatomic, strong) ADJAttribution *attributionUpdated;

- (void)setUpdatedAttribution:(BOOL)updated;

@end
