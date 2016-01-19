//
//  NetworkActivityController.m
//  Globus
//
//  Created by Mladen Djordjevic on 3/23/12.
//  Copyright 2012 Youngculture. All rights reserved.

#import "NetworkActivityController.h"
#import "AppDelegate.h"

@interface NetworkActivityController ()

@property (nonatomic, strong) UIAlertView *myAlertView;
@property (nonatomic) NSInteger activityCount;

@end

@implementation NetworkActivityController

@synthesize myAlertView = _myAlertView;
@synthesize activityCount = _activityCount;

#pragma mark - Singleton Methods

+ (NetworkActivityController*)sharedInstance {

	static NetworkActivityController *_sharedInstance;
	if(!_sharedInstance) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedInstance = [[super allocWithZone:nil] init];
            _sharedInstance.activityCount = 0;
        });
    }

    return _sharedInstance;
}


#pragma mark - Custom Methods

- (void)setActivityVisible:(BOOL)visible {
    /*
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:visible];
    if(!_myAlertView) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading\nPlease Wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        self.myAlertView = alert;
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.center = CGPointMake(284 / 2, 90);
        [indicator startAnimating];
        [_myAlertView addSubview:indicator];
        
    }
    if(visible) {
        _activityCount++;
        if(_activityCount == 1) {
            [_myAlertView show];
        }
    } else {
        _activityCount--;
        if(_activityCount == 0){
            [_myAlertView dismissWithClickedButtonIndex:0 animated:YES];
        }
    }*/
}


@end
