//
//  LoginFormViewController.h
//  Globus
//
//  Created by Patrik Oprandi on 16.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCellFormViewController.h"
#import "AddressBookUI/AddressBookUI.h"
#import "ABButton.h"
#import "WebViewController.h"
#import "UserJSONReader.h"
#import "WebserviceWithAuth.h"
#import "BrowserViewController.h"

extern NSString *const GlobusLoginNotification;

@protocol LoginFormDelegate;

@interface LoginFormViewController : CustomCellFormViewController <UIAlertViewDelegate, ABWebserviceDelegate,WebserviceAuthDataSource,WebserviceLoadingTextDataSource>
{
	
@private
	UserJSONReader *userJSONReader;
	
	IBOutlet WebViewController *forgetPasswordWebViewController;
	id<LoginFormDelegate> formDelegate;
	NSString *trackingName;
	NSString *trackingCategory;
}

@property (nonatomic, unsafe_unretained) __unsafe_unretained id<LoginFormDelegate> formDelegate;
@property (nonatomic, retain) NSString *trackingName, *trackingCategory;

@end

@protocol LoginFormDelegate <NSObject>

- (void)userDidLogIn;
- (void)userDidFailToLogInWithError:(NSError*)error;
@optional
- (void)controllerDidFinishDismissAnimation;


@end

