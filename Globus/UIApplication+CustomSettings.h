//
//  UIApplication+CustomSettings.h
//  Globus
//
//  Created by Marko Tadic on 4/14/16.
//
//

#import <UIKit/UIKit.h>

@interface UIApplication (CustomSettings)

#pragma mark - API

+ (NSString *)serverAddress;

+ (BOOL)isDebug;
+ (BOOL)isStage;

@end
