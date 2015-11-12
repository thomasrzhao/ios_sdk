//
//  ADJEvent.h
//  adjust GmbH
//
//  Created by Pedro Filipe on 15/10/14.
//  Copyright (c) 2014-2015 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJEvent : NSObject <NSCopying>

/**
 *  @property   emptyReceipt
 *
 *  @brief      Boolean indicating wether receipt was set or not.
 */
@property (nonatomic, assign, readonly) BOOL emptyReceipt;

/**
 *  @property   receipt
 *
 *  @brief      Receipt which is being validated.
 */
@property (nonatomic, copy, readonly) NSData *receipt;

/**
 *  @property   revenue
 *
 *  @brief      Revenue value set by user.
 */
@property (nonatomic, copy, readonly) NSNumber *revenue;

/**
 *  @property   currency
 *
 *  @brief      Three character string mark for currency set by user.
 */
@property (nonatomic, copy, readonly) NSString *currency;

/**
 *  @property   eventToken
 *
 *  @brief      Six character string event token.
 */
@property (nonatomic, copy, readonly) NSString *eventToken;

/**
 *  @property   transactionId
 *
 *  @brief      SKPaymentTransaction identifier of transaction which is being validated.
 */
@property (nonatomic, copy, readonly) NSString *transactionId;

/**
 *  @property   callbackParameters
 *
 *  @brief      Dictionary of parameters which are going to be attached to callback URL.
 */
@property (nonatomic, readonly) NSDictionary *callbackParameters;

/**
 *  @property   partnerParameters
 *
 *  @brief      Dictionary of parameters which are going to be forwarded to a partner.
 */
@property (nonatomic, readonly) NSDictionary *partnerParameters;

/**
 *  @brief  Create Event object with given event token.
 *
 *  @param  eventToken  Event token that is created in the dashboard
 *                      at http://adjust.com and should be six characters long.
 */
+ (ADJEvent *)eventWithEventToken:(NSString *)eventToken;
- (id)initWithEventToken:(NSString *)eventToken;

/**
 *  @brief  Set the revenue and associated currency of the event.
 *
 *          The event can contain some revenue. The amount revenue is measured in units.
 *          It must include a currency in the ISO 4217 format.
 *
 *  @param  amount      The amount in units (example: for 1.50 EUR is 1.5)
 *  @param  currency    String of the currency with ISO 4217 format.
 *                      It should be 3 characters long (example: for 1.50 EUR is @"EUR")
 */
- (void)setRevenue:(double)amount
          currency:(NSString *)currency;

/**
 *  @brief  Add a key-pair to a callback URL.
 *
 *          In your dashboard at http://adjust.com you can assign a callback URL to each
 *          event type. That URL will get called every time the event is triggered. On
 *          top of that you can add callback parameters to the following method that
 *          will be forwarded to these callbacks.
 *
 *  @param  key     String key in the callback URL.
 *  @param  value   String value of the key in the Callback URL.
 *
 */
- (void)addCallbackParameter:(NSString *)key
                       value:(NSString *)value;

/**
 *  @brief   Add a key-pair to be fowarded to a partner.
 *
 *  @param  key     String key to be fowarded to the partner.
 *  @param  value   String value of the key to be fowarded to the partner.
 *
 */
- (void)addPartnerParameter:(NSString *)key
                      value:(NSString *)value;

/**
 *  @brief  Set the transaction ID of a In-App Purchases to avoid revenue duplications.
 *
 *          A transaction ID can be used to avoid duplicate revenue events. The last ten
 *          transaction identifiers are remembered.
 *
 *  @param  transactionId   The identifier used to avoid duplicate revenue events.
 */
- (void)setTransactionId:(NSString *)transactionId;

/**
 *  @brief  Validate a In-App-Purchase receipt.
 *
 *  @param  receipt         The receipt to validate.
 *  @param  transactionId   The identifier used to validate the receipt and to avoid duplicate revenue events.
 */
- (void)setReceipt:(NSData *)receipt
     transactionId:(NSString *)transactionId;

/**
 *  @brief  Check if created ADJEvent object is valid.
 *
 *  @return Boolean indicating wether ADJEvent object is valid.
 */
- (BOOL)isValid;

@end
