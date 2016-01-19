//
//  WebserviceWithProxy.m
//  Globus
//
//  Created by Mladen Djordjevic on 3/23/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "WebserviceWithProxy.h"
#import "WebserviceProxy.h"

@interface WebserviceWithProxy ()

@property (nonatomic, strong) WebserviceProxy *delegateProxy;

@end

@implementation WebserviceWithProxy

@synthesize delegateProxy = _delegateProxy;
@synthesize loadingTextDataSource = _loadingTextDataSource;

- (void)setDelegate:(id<ABWebserviceDelegate>)theDelegate {
    if(!_delegateProxy) {
        self.delegateProxy = [[WebserviceProxy alloc] init];
        delegate = _delegateProxy;
    }
    _delegateProxy.delegate = theDelegate;
}
- (void)setLoadingTextDataSource:(id<WebserviceLoadingTextDataSource>)theDataSource {
    if(!_delegateProxy) {
        self.delegateProxy = [[WebserviceProxy alloc] init];
        delegate = _delegateProxy;
    }
    _delegateProxy.loadingTextDataSource = theDataSource;
    
}

@end
