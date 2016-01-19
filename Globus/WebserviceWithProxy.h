//
//  WebserviceWithProxy.h
//  Globus
//
//  Created by Mladen Djordjevic on 3/23/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABWebservice.h"

@protocol WebserviceLoadingTextDataSource;

@interface WebserviceWithProxy : ABWebservice

@property (nonatomic, unsafe_unretained) __unsafe_unretained id<WebserviceLoadingTextDataSource> loadingTextDataSource;

@end

@protocol WebserviceLoadingTextDataSource <NSObject>

- (NSString*)loadingText;

@end
