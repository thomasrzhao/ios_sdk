//
//  ADJAttribution.h
//  adjust GmbH
//
//  Created by Pedro Filipe on 29/10/14.
//  Copyright (c) 2014-2015 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Adjust attribution info object.
 */
@interface ADJAttribution : NSObject <NSCoding, NSCopying>

// The following attributes are only set when error is nil.
// (when activity was tracked successfully and response could be parsed)

/**
 *  @property   trackerToken
 *
 *  @brief  Attribution info tracker token.
 */
@property (nonatomic, copy) NSString *trackerToken;

/**
 *  @property   trackerName
 *
 *  @brief  Attribution info tracker name.
 */
@property (nonatomic, copy) NSString *trackerName;

/**
 *  @property   network
 *
 *  @brief  Attribution info network name.
 */
@property (nonatomic, copy) NSString *network;

/**
 *  @property   campaign
 *
 *  @brief  Attribution info campaign name.
 */
@property (nonatomic, copy) NSString *campaign;

/**
 *  @property   adgroup
 *
 *  @brief  Attribution info ad group name.
 */
@property (nonatomic, copy) NSString *adgroup;

/**
 *  @property   campaign
 *
 *  @brief  Attribution info creative name.
 */
@property (nonatomic, copy) NSString *creative;

/**
 *  @property   click label
 *
 *  @brief  Attribution info click label info.
 */
@property (nonatomic, copy) NSString *clickLabel;

/**
 *  @brief  Attribution object returned by SDK with install attribution info.
 *
 *  @param jsonDict Dictionary with attribution info.
 */
+ (ADJAttribution *)dataWithJsonDict:(NSDictionary *)jsonDict;
- (id)initWithJsonDict:(NSDictionary *)jsonDict;

/**
 *  @brief  Get attribution info as NSDictionary object.
 *
 *  @return NSDictionary object containing attribution.
 */
- (NSDictionary *)dictionary;

/**
 *  @brief  Check if given attribution equals current one.
 *
 *  @return Boolean indicating wether two attributions are the same.
 */
- (BOOL)isEqualToAttribution:(ADJAttribution *)attribution;

@end
