//
//  WebserviceProxy.h
//  Globus
//
//  Created by Mladen Djordjevic on 3/23/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABWebservice.h"
#import "WebserviceWithProxy.h"

@interface WebserviceProxy : NSObject <ABWebserviceDelegate,WebserviceLoadingTextDataSource>

@property (nonatomic, unsafe_unretained) __unsafe_unretained id<ABWebserviceDelegate> delegate;
@property (nonatomic, unsafe_unretained) __unsafe_unretained id<WebserviceLoadingTextDataSource> loadingTextDataSource;

@end
