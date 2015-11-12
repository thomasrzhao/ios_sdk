//
//  NSURLConnection+NSURLConnectionSynchronousLoadingMocking.h
//  adjust GmbH
//
//  Created by Pedro Filipe on 12/02/14.
//  Copyright (c) 2014-2015 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ADJResponseTypeNil = 0,
    ADJResponseTypeConnError = 1,
    ADJResponseTypeWrongJson = 2,
    ADJResponseTypeEmptyJson = 3,
    ADJResponseTypeServerError = 4,
    ADJResponseTypeMessage = 5,
} ADJResponseType;

@interface NSURLConnection(NSURLConnectionSynchronousLoadingMock)

+ (void)reset;
+ (void)setResponseType:(ADJResponseType)responseType;

+ (NSURLRequest *)getLastRequest;
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error;

@end
