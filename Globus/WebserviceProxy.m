//
//  WebserviceProxy.m
//  Globus
//
//  Created by Mladen Djordjevic on 3/23/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "WebserviceProxy.h"
#import "NetworkActivityController.h"
#import "InfoView.h"

@interface WebserviceProxy ()

- (void)setActivityIndicatorVisible:(BOOL)visible;

@end

@implementation WebserviceProxy

@synthesize delegate = _delegate;
@synthesize loadingTextDataSource = _loadingTextDataSource;

- (void) webservice:(ABWebservice *)theWebservice didFinishWithObject:(id)theObject {
    if([_delegate respondsToSelector:@selector(webservice:didFinishWithObject:)]) {
        [_delegate webservice:theWebservice didFinishWithObject:theObject];
    }
    [self setActivityIndicatorVisible:NO];
}
- (void) webservice:(ABWebservice *)theWebservice didFailWithError:(NSError *)theError {
    if([_delegate respondsToSelector:@selector(webservice:didFailWithError:)]){
        [_delegate webservice:theWebservice didFailWithError:theError];
    }
    [self setActivityIndicatorVisible:NO];
}
- (void) webserviceWillStart:(ABWebservice *)theWebservice {
    if([_delegate respondsToSelector:@selector(webserviceWillStart:)]){
        [_delegate webserviceWillStart:theWebservice];
    }
    [self setActivityIndicatorVisible:YES];
}
- (void) webserviceDidFinishSending:(ABWebservice *)theWebservice {
    if([_delegate respondsToSelector:@selector(webserviceDidFinishSending:)]){
        [_delegate webserviceDidFinishSending:theWebservice];
    }
}
- (void) webserviceDidStartLoading:(ABWebservice *)theWebservice {
    [self setActivityIndicatorVisible:YES];
    if([_delegate respondsToSelector:@selector(webserviceDidStartLoading:)]){
        [_delegate webserviceDidStartLoading:theWebservice];
    }
}
- (void) webserviceDidFinishLoading:(ABWebservice *)theWebservice {
    [self setActivityIndicatorVisible:NO];
    if([_delegate respondsToSelector:@selector(webserviceDidFinishLoading:)]){
        [_delegate webserviceDidFinishLoading:theWebservice];
    }
}
- (void) webserviceDidCancel:(ABWebservice *)theWebservice {
    if([_delegate respondsToSelector:@selector(webserviceDidCancel:)]){
        [_delegate webserviceDidCancel:theWebservice];
    }
    [self setActivityIndicatorVisible:NO];
}
- (void) webservice:(ABWebservice *)theWebservice didChangeProgress:(float)progress {
    if([_delegate respondsToSelector:@selector(webservice:didChangeProgress:)]){
        [_delegate webservice:theWebservice didChangeProgress:progress];
    }
}

- (void)setActivityIndicatorVisible:(BOOL)visible {
    InfoView *iView = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([_delegate respondsToSelector:@selector(infoView)]) {
        iView = [_delegate performSelector:@selector(infoView)];
    }
#pragma clang diagnostic pop
    if(iView) {
        if(visible) {
            [iView showLoadingWithText:[_loadingTextDataSource loadingText] animated:YES];
        } else {
            [iView hideAnimated:YES];
        }
        
    }
}
- (NSString*)loadingText {
    if([_loadingTextDataSource respondsToSelector:@selector(loadingText)]){
        return [_loadingTextDataSource performSelector:@selector(loadingText)];
    }
    return @"";
}

@end
