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
    NSString *url = [[self customSettings] objectForKey:@"ServerAddress"];
    return url;
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

+ (NSString *)appConfiguration {
    NSString *configuration = [[self customSettings] objectForKey:@"Configuration"];
    return configuration;
}

+ (BOOL)configurationContainsString:(NSString *)string {
    BOOL contains = [[[self appConfiguration] lowercaseString] containsString:string];
    return contains;
}

@end
