//
//  SystemUserSingleton.m
//  Globus
//
//  Created by Mladen Djordjevic on 4/11/12.
//  Copyright 2012 Youngculture. All rights reserved.

#import "SystemUserSingleton.h"

@interface SystemUserSingleton()
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@end

@implementation SystemUserSingleton

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - API

- (NSString *)username {
    if (!_username) {
        _username = [UIApplication serverUsername];
    }
    return _username;
}

- (NSString *)password {
    if (!_password) {
        _password = [UIApplication serverPassword];
    }
    return _password;
}

@end
