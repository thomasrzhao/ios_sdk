//
//  Adjust.h
//  adjust GmbH
//
//  Created by Christian Wellenbrock on 23/07/2012.
//  Copyright (c) 2012-2015 adjust GmbH. All rights reserved.
//

#import "ADJEvent.h"
#import "ADJConfig.h"
#import "ADJAttribution.h"

/**
 * Constants for our supported tracking environments.
 */
extern NSString * const ADJEnvironmentSandbox;
extern NSString * const ADJEnvironmentProduction;

/**
 *  @brief  The main interface to Adjust.
 *
 *          Use the methods of this class to tell Adjust about the usage of your app.
 *          See the README for details.
 */
@interface Adjust : NSObject

/**
 *  @brief  Tell Adjust that the application did launch.
 *
 *          This is required to initialize Adjust. Call this in the didFinishLaunching
 *          method of your AppDelegate.
 *
 *          See ADJConfig.h for more configuration options.
 *
 * @param adjustConfig  The configuration object that includes the environment
 *                      and the App Token of your app. This unique identifier can
 *                      be found it in your dashboard at http://adjust.com and should always
 *                      be twelve characters long.
 */
+ (void)appDidLaunch:(ADJConfig *)adjustConfig;

/**
 *  @brief  Tell Adjust that a particular event has happened.
 *
 *          See ADJEvent.h for more event options.
 *
 *  @param event    The Event object for this kind of event. It needs a event token
 *                  that is  created in the dashboard at http://adjust.com and should be six
 *                  characters long.
 */
+ (void)trackEvent:(ADJEvent *)event;

/**
 *  @brief  Tell adjust that the application resumed.
 *
 *          Only necessary if the native notifications can't be used.
 */
+ (void)trackSubsessionStart;

/**
 *  @brief  Tell adjust that the application paused.
 *
 *          Only necessary if the native notifications can't be used.
 */
+ (void)trackSubsessionEnd;

/**
 *  @brief  Enable or disable the adjust SDK. This setting is saved
 *          for future sessions.
 *
 *  @param enabled   The flag to enable or disable the adjust SDK.
 */
+ (void)setEnabled:(BOOL)enabled;

/**
 *  @brief  Check if the SDK is enabled or disabled.
 *
 *  @return Boolean indicating wether SDK is enabled or not.
 */
+ (BOOL)isEnabled;

/**
 *  @brief  Read the URL that opened the application to search for
 *          an adjust deep link.
 *
 *  @param  url URL which opened the app.
 */
+ (void)appWillOpenUrl:(NSURL *)url;

/**
 *  @brief  Set the device token used by push notifications.
 *
 *  @param  deviceToken Push notifications device token.
 */
+ (void)setDeviceToken:(NSData *)deviceToken;

/**
 *  @brief  Enable or disable offline mode. Activities won't be sent
 *          but they are saved when offline mode is disabled. This
 *          feature is not saved for future sessions.
 *
 *  @param  enabled Boolean indicating should offline mode be enabled 
 *                  or disabled.
 */
+ (void)setOfflineMode:(BOOL)enabled;

/**
 *  @brief  Obtain singleton Adjust object.
 */
+ (id)getInstance;

- (BOOL)isEnabled;
- (void)trackSubsessionEnd;
- (void)trackSubsessionStart;
- (void)setEnabled:(BOOL)enabled;
- (void)appWillOpenUrl:(NSURL *)url;
- (void)setOfflineMode:(BOOL)enabled;
- (void)trackEvent:(ADJEvent *)event;
- (void)setDeviceToken:(NSData *)deviceToken;
- (void)appDidLaunch:(ADJConfig *)adjustConfig;

@end

