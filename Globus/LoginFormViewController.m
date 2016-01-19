//
//  LoginFormViewController.m
//  Globus
//
//  Created by Patrik Oprandi on 16.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "GlobusController.h"
#import "LoginFormViewController.h"
#import "StylesheetController.h"
#import "User.h"
#import "UserResult.h"
#import "ManagedUser.h"
#import "BorderedButtonController.h"
#import "BorderedView.h"
#import "TextFormfieldCell.h"

#define kiPhoneFontSize 16.0
#define kiPadFontSize 20.0

NSString *const GlobusLoginNotification = @"GlobusLoginNotification";


@interface LoginFormViewController ()

- (void)formfieldDidChangeNotification:(NSNotification *)theNotification;

- (void)formFirstFieldFocus;
- (void)errorHandlerShowWithError:(NSError *)theError;
- (void)forgottenPasswordBtnTouched;

@end


@implementation LoginFormViewController

@synthesize formDelegate = _formDelegate;
@synthesize trackingName = _trackingName;
@synthesize trackingCategory = _trackingCategory;

#pragma mark - Housekeeping

- (id)initWithCoder:(NSCoder *)theDecoder
{
	if ((self = [super initWithCoder:theDecoder]))
	{
		userJSONReader = [[UserJSONReader alloc] init];
		userJSONReader.delegate = self;
        userJSONReader.dataSource = self;
        userJSONReader.loadingTextDataSource = self;
	}
	
	return self;
}


#pragma mark - GUI startup & shutdown

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if (!formDictionary)
	{
		[super loadFormWithName:@"LoginForm"];
		
		// customize tableview
		tableView.sectionFooterHeight = 0.0;
		
		/*BorderedView *forgetView = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"ForgetPassButton"];
        [[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(forgottenPasswordBtnTouched) forBorderedView:forgetView];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:forgetView];*/
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formfieldDidChangeNotification:) name:FormfieldDidChangeNotification object:nil];
    
    [self setFormfieldValue:nil forName:@"pwd"];
    [self setFormfieldValue:nil forName:@"Email"];
	
	
	UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 80.0)];
	
	UIButton *forgetPassButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[forgetPassButton setTitle:NSLocalizedString(@"All.ForgetPasswordText", @"") forState:UIControlStateNormal];
	[forgetPassButton setTitleColor:[UIColor colorWithRed:119.0/255.0 green:102.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
	[forgetPassButton setTitleColor:[UIColor colorWithRed:79.0/255.0 green:62.0/255.0 blue:11.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
	forgetPassButton.titleLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize];
	forgetPassButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	[forgetPassButton addTarget:self action:@selector(forgottenPasswordBtnTouched) forControlEvents:UIControlEventTouchUpInside];
	forgetPassButton.frame = CGRectMake((self.tableView.frame.size.width/2) - 100.0, 18.0, 200.0, 30.0);
	
	CGSize tmpSize = [NSLocalizedString(@"All.ForgetPasswordText", @"") boundingRectWithSize:CGSizeMake(200.0, 30.0) options:kNilOptions attributes:@{NSFontAttributeName:forgetPassButton.titleLabel.font} context:nil].size;
	UIView *line = [[UIView alloc] initWithFrame:CGRectMake(100 - (tmpSize.width / 2), 23.0, tmpSize.width, 1)];
	line.backgroundColor = [UIColor colorWithRed:119.0/255.0 green:102.0/255.0 blue:51.0/255.0 alpha:1.0];
	[forgetPassButton addSubview:line];

	if([self isModal])
	{
		BorderedView *cancelButton = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"CancelButton"];
		[[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(cancelAction) forBorderedView:cancelButton];
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
	} else
	{
		BorderedView *backButton = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"BackButton"];
		backButton.touchTreshold = 10;
		[[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(cancelAction) forBorderedView:backButton];
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	}	
	
	[buttonView addSubview:forgetPassButton];
	self.tableView.tableFooterView = buttonView;
	
	User *currentUser = [[GlobusController sharedInstance] loggedUser];
	[self setFormfieldValue:currentUser.email forName:@"Email" updateCell:YES];
	
	self.pageName = _trackingName;
	[[GlobusController sharedInstance] analyticsTrackPageview:[self.navigationController pagePath]];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self formFirstFieldFocus];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:FormfieldDidChangeNotification object:nil];
	[userJSONReader stop];
}

- (NSUInteger)supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
	else
		return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Overwritting super class methods

- (FormfieldCell *)formViewController:(FormViewController *)theFormViewController cellForFormfield:(NSDictionary *)formfieldDictionary
{
	FormfieldCell *cell;
	
	cell = [super formViewController:theFormViewController cellForFormfield:formfieldDictionary];
		
	if ([[formfieldDictionary valueForKey:@"Type"] isEqualToString:@"Picker"])
		cell.userInteractionEnabled = YES;
		
	return cell;
}

- (BOOL)formViewControllerShouldSave:(FormViewController *)formViewController
{
	if ([self hasMissingRequiredFormfields])
	{
        [[GlobusController sharedInstance] alertWithType:@"Login" messageKey:@"UsernameOrPasswordAreMisssing"];
		
		return NO;
	}
	
	[[GlobusController sharedInstance] analyticsTrackEvent:_trackingCategory action:@"Click" label:@"Login" value:@0];
	[userJSONReader login];
	
	return YES;
}

- (void)formViewControllerDidCancel:(FormViewController *)theFormViewController {
	[[GlobusController sharedInstance] analyticsTrackEvent:_trackingCategory action:@"Cancel" label:@"Login" value:@0];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)formViewController:(FormViewController *)formViewController shouldDisplayFormfield:(NSDictionary *)formfieldDictionary
{
	if ([formViewController.formName isEqualToString:@"Registration"])
	{
		
	}
	
	return YES;
}

- (void)cancelAction
{
	[[GlobusController sharedInstance] analyticsTrackEvent:_trackingCategory action:@"Cancel" label:@"Login" value:@0];
	
	[super cancelAction];
	
	if([self isModal])
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	else
		[self.navigationController popViewControllerAnimated:YES];
}

- (void)formViewController:(FormViewController *)formViewController didSelectRow:(NSDictionary *)formfieldDictionary
{
	if ([formViewController.formName isEqualToString:@"Login"])
	{
		if ([[formfieldDictionary valueForKey:@"Type"] isEqualToString:@"Button"])
		{
			if ([[formfieldDictionary valueForKey:@"Name"] isEqualToString:@"LoginButton"])
			{
				[self saveAction];
			}
		}
	}
}


#pragma mark - Helper functions

- (void)formFirstFieldFocus
{
	if ([self.formName isEqualToString:@"Login"] || [self.formName isEqualToString:@"OrderLogin"])
	{
		if ([self formfieldValueForName:@"EmailAddress"].length > 0)
			[self focusForFormfieldName:@"Password"];
		else
			[self focusForFormfieldName:@"EmailAddress"];
	}
	else if ([self.formName isEqualToString:@"PasswordReset"])
		[self focusForFormfieldName:@"EmailAddress"];
}

- (void)errorHandlerShowWithError:(NSError *)theError
{

}

- (IBAction)registrationBarButtonAction:(id)sender
{
	[self saveAction];
}


#pragma mark - Alerts

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Notifications

- (void)formfieldDidChangeNotification:(NSNotification *)theNotification
{
	NSDictionary *formfieldDictionary = (NSDictionary *)theNotification.object;
	NSString *name = [formfieldDictionary valueForKey:@"Name"];
	
	if ([name isEqualToString:@"CreateAccount"])
		[self reloadFormAnimated];
	
	else if ([name isEqualToString:@"ZipCode"] || [name isEqualToString:@"DeliveryZipCode"])
	{
		[self reloadFormAnimated];
	}
}


#pragma mark - ABWebservice delegates

- (void)webserviceWillStart:(ABWebservice *)theWebservice
{
	//do nothing
}

- (void)webservice:(ABWebservice *)theWebservice didFinishWithObject:(id)theObject
{
	if (theWebservice == userJSONReader)
	{
		if (![theObject isKindOfClass:[NSError class]])
		{
			if([_formDelegate respondsToSelector:@selector(userDidLogIn)]){
				[_formDelegate userDidLogIn];
			}
			
			if ([[[[GlobusController sharedInstance] loggedUser] language] isEqualToString:@"I"] && [[[GlobusController sharedInstance] couponLanguage] length] == 0 && [NSLocalizedString(@"All.LanguageCode", @"") isEqualToString:@"en"])
			{
				[[GlobusController sharedInstance] alert:@"Alert.Coupons.Language.TitleText" withBody:@"Alert.Coupons.Language.BodyText" firstButtonNamed:@"Registration.LanguageGermanText" withExtraButtons:[NSArray arrayWithObject:@"Registration.LanguageFrenchText"] tag:1 informing:self];
			} else 
			{
				[[NSNotificationCenter defaultCenter] postNotificationName:GlobusLoginNotification object:nil];
				[[GlobusController sharedInstance] startLoadingStores];
				
				[self.navigationController dismissViewControllerAnimated:YES completion:nil];
				
				if([self.formDelegate respondsToSelector:@selector(controllerDidFinishDismissAnimation)])
				{
					[self.formDelegate controllerDidFinishDismissAnimation];
				}
				
				
			}
		}
        
	}
}

- (void)webservice:(ABWebservice *)theWebservice didFailWithError:(NSError *)theError
{
	if (theWebservice == userJSONReader)
	{
        
        if(theError.code == -1012){
            [[GlobusController sharedInstance] setLoggedUser:[[ManagedUser sharedInstance] userData]];
            [[GlobusController sharedInstance] alertWithType:@"Login" messageKey:@"WrongUsernameOrPassword"];
        } else if (theError.code == -1004  || theError.code == -1009) {
            [[GlobusController sharedInstance] setLoggedUser:[[ManagedUser sharedInstance] userData]];
            [[GlobusController sharedInstance] alertWithType:@"Login" message:NSLocalizedString(@"All.ConnectErrorText", @"")];
        } 
		else
		{
			[[GlobusController sharedInstance] setLoggedUser:[[ManagedUser sharedInstance] userData]];
            [[GlobusController sharedInstance] alertWithType:@"Login" message:NSLocalizedString(@"All.ConnectErrorText", @"")];
		}
		
        if([_formDelegate respondsToSelector:@selector(userDidFailToLogInWithError:)]){
            [_formDelegate userDidFailToLogInWithError:theError];
        }
		
	}
}


#pragma mark - UIAlertView delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		[[NSUserDefaults standardUserDefaults] setValue:@"D" forKey:@"couponLanguage"];
		[[GlobusController sharedInstance] setCouponLanguage:@"D"];
	}
    if (buttonIndex == 1)
	{
		[[NSUserDefaults standardUserDefaults] setValue:@"F" forKey:@"couponLanguage"];
		[[GlobusController sharedInstance] setCouponLanguage:@"F"];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:GlobusLoginNotification object:nil];
	[[GlobusController sharedInstance] startLoadingStores];
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
				
	if([self.formDelegate respondsToSelector:@selector(controllerDidFinishDismissAnimation)])
	{
		[self.formDelegate controllerDidFinishDismissAnimation];
	}

}


#pragma mark - WebserviceWithAuthDataSource

- (NSString*)username {
    return [[self formfieldValueForName:@"Email"] lowercaseString];
}

- (NSString*)password {
    return [self formfieldValueForName:@"pwd"];
}

- (void)forgottenPasswordBtnTouched {
	[[GlobusController sharedInstance] analyticsTrackEvent:_trackingCategory action:@"Click" label:@"ForgetPassword" value:@0];
	
	NSString *lang = NSLocalizedString(@"All.LanguageCode", @"");
	NSString *url;
	
	if ([lang isEqualToString:@"en"])
	{
		NSString *corLang = [[GlobusController sharedInstance] userSelectedLang];
		if ([corLang isEqualToString:@"fr"])
			url = NSLocalizedString(@"Login.PasswordReset.Fr.Url", @"");
		else
			url = NSLocalizedString(@"Login.PasswordReset.Url", @"");
	} else
		url = NSLocalizedString(@"Login.PasswordReset.Url", @"");
	
	
	
	NSString *urlString;
	if ([self formfieldValueForName:@"Email"].length > 0)
		urlString = [NSString stringWithFormat:@"%@?email=%@", url, [self formfieldValueForName:@"Email"]];
	else
		urlString = url;
    forgetPasswordWebViewController.URLString = urlString;
	forgetPasswordWebViewController.title = NSLocalizedString(@"Login.PasswordReset.TitleText", @"");
	[self.navigationController pushViewController:forgetPasswordWebViewController animated:YES];
}

- (NSString*)loadingText {
    return @"Login";
}

@end
