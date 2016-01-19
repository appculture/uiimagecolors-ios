//
//  ABWebserviceWithAuth.h
//  Globus
//
//  Created by Mladen Djordjevic on 3/1/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceWithProxy.h"

@protocol WebserviceAuthDataSource;

@interface WebserviceWithAuth : WebserviceWithProxy

@property (nonatomic, unsafe_unretained) __unsafe_unretained id <WebserviceAuthDataSource> dataSource;

@end

@protocol WebserviceAuthDataSource <NSObject>

-(NSString*)username;
-(NSString*)password;

@end