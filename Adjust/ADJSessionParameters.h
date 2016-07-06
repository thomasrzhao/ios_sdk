//
//  ADJSessionParameters.h
//  Adjust
//
//  Created by Pedro Filipe on 27/05/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJSessionParameters : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSMutableDictionary* callbackParameters;
@property (nonatomic, strong) NSMutableDictionary* partnerParameters;
@property (nonatomic, copy) NSString *customUserId;

@end
