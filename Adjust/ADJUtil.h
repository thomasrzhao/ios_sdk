//
//  ADJUtil.h
//  adjust GmbH
//
//  Created by Christian Wellenbrock on 05/07/2013.
//  Copyright (c) 2013-2015 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJActivityKind.h"

@interface ADJUtil : NSObject

+ (BOOL)isNull:(id)value;
+ (void)excludeFromBackup:(NSString *)filename;
+ (NSDictionary *)buildJsonDict:(NSData *)jsonData;

+ (NSString *)baseUrl;
+ (NSString *)clientSdk;
+ (NSString *)formatDate:(NSDate *)value;
+ (NSString *)formatSeconds1970:(double)value;
+ (NSString *)queryString:(NSDictionary *)parameters;
+ (NSString *)getFullFilename:(NSString *)baseFilename;

+ (id)readObject:(NSString *)filename
      objectName:(NSString *)objectName
           class:(Class)classToRead;

+ (void)writeObject:(id)object
           filename:(NSString *)filename
         objectName:(NSString *)objectName;

+ (void)sendRequest:(NSMutableURLRequest *)request
 prefixErrorMessage:(NSString *)prefixErrorMessage
jsonResponseHandler:(void (^)(NSDictionary *jsonDict))jsonResponseHandler;

+ (void)sendRequest:(NSMutableURLRequest *)request
 prefixErrorMessage:(NSString *)prefixErrorMessage
 suffixErrorMessage:(NSString *)suffixErrorMessage
jsonResponseHandler:(void (^)(NSDictionary *jsonDict))jsonResponseHandler;

@end
