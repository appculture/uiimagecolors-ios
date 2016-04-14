//
//  UIApplication+CustomSettings.m
//  Globus
//
//  Created by Marko Tadic on 4/14/16.
//
//

#import "UIApplication+CustomSettings.h"

@implementation UIApplication (CustomSettings)

#pragma mark - API

+ (NSString *)serverAddress {
    return [self customSettingForKey:@"ServerAddress"];
}

+ (NSString *)serverUsername {
    return [self customSettingForKey:@"ServerUsername"];
}

+ (NSString *)serverPassword {
    return [self customSettingForKey:@"ServerPassword"];
}

+ (BOOL)isStage {
    return [self configurationContainsString:@"stage"];
}

+ (BOOL)isDebug {
    return [self configurationContainsString:@"debug"];
}

#pragma mark - Helpers

+ (NSDictionary *)customSettings {
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *settings = [bundle objectForInfoDictionaryKey:@"CustomSettings"];
    return settings;
}

+ (id)customSettingForKey:(NSString *)key {
    id setting = [[self customSettings] objectForKey:key];
    return setting;
}

+ (NSString *)appConfiguration {
    return [self customSettingForKey:@"Configuration"];
}

+ (BOOL)configurationContainsString:(NSString *)string {
    BOOL contains = [[[self appConfiguration] lowercaseString] containsString:string];
    return contains;
}

@end
