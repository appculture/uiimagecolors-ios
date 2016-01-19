//
//  ChangePasswordFormViewController.m
//  Globus
//
//  Created by Patrik Oprandi on 26.03.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "ChangePasswordFormViewController.h"
#import "GlobusController.h"
#import "User.h"
#import "BorderedButtonController.h"
#import "BorderedView.h"
#import "ProfileViewController.h"
#import "User.h"
#import "ManagedUser.h"

@interface ChangePasswordFormViewController ()

- (NSString *)buildJSONStringForRegistrationWithDictionary:(NSDictionary *)theDictionary;
- (void)cancelButtonTouched;
- (void)goBackToProfileVC;
- (void)storeNewUserData;

@end

@implementation ChangePasswordFormViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		changePasswordJSONReader = [[ChangePasswordJSONReader alloc] init];
		changePasswordJSONReader.delegate = self;
		changePasswordJSONReader.dataSource = self;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)theDecoder
{
	if (self = [super initWithCoder:theDecoder])
	{
        changePasswordJSONReader = [[ChangePasswordJSONReader alloc] init];
		changePasswordJSONReader.delegate = self;
		changePasswordJSONReader.dataSource = self;
	}
	
	return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if (!formDictionary)
	{
		[super loadFormWithName:@"ChangePasswordForm"];
		
		// customize tableview
		tableView.sectionFooterHeight = 0.0;
        self.delegate = self;
        BorderedView *cancelButton = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"CancelButton"];
        [[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(cancelButtonTouched) forBorderedView:cancelButton];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formfieldDidChangeNotification:) name:FormfieldDidChangeNotification object:nil];
    
    [self setFormfieldValue:nil forName:@"newPwd" updateCell:YES];
    [self setFormfieldValue:nil forName:@"newPwdConfirm" updateCell:YES];
	
	self.pageName = @"changepassword";
	[[GlobusController sharedInstance] analyticsTrackPageview:[self.navigationController pagePath]];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FormfieldDidChangeNotification object:nil];
    
	[changePasswordJSONReader stop];
}

- (NSUInteger)supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
	else
		return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Overwritting super class methods


- (BOOL)formViewController:(FormViewController *)formViewController shouldDisplayFormfield:(NSDictionary *)formfieldDictionary
{
	
	return YES;
}

- (void)formViewControllerDidCancel:(FormViewController *)theFormViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
//}

- (void)formfieldDidChangeNotification:(NSNotification *)theNotification
{
	
}


- (BOOL)formViewControllerShouldSave:(FormViewController *)formViewController
{
	if ([self hasMissingRequiredFormfields])
	{
		if ([formViewController.formName isEqualToString:@"ChangePassword"])
			[[GlobusController sharedInstance] alertWithType:@"ChangePassword" messageKey:@"MissingFields"];
		
		return NO;
	}
	
	if ([formViewController.formName isEqualToString:@"ChangePassword"])
	{
		if ([self formfieldValueForName:@"newPwd"].length < 6)
		{
			[[GlobusController sharedInstance] alertWithType:@"ChangePassword" messageKey:@"PasswordToShort"];
			[self setFormfieldValue:nil forName:@"newPwd"];
			
			return NO;
		} else if (![[self formfieldValueForName:@"newPwd"] isEqualToString:[self formfieldValueForName:@"newPwdConfirm"]])
		{
			[[GlobusController sharedInstance] alertWithType:@"ChangePassword" messageKey:@"WrongConfirmPassword"];
			[self setFormfieldValue:nil forName:@"newPwdConfirm"];
			
			return NO;
		}

		[[GlobusController sharedInstance] analyticsTrackEvent:@"ChangePassword" action:@"Click" label:@"ChangePassword" value:@0];
		
		NSString *jsonString = [self buildJSONStringForRegistrationWithDictionary:valueDictionary];
		
		[changePasswordJSONReader changePasswordWithBody:jsonString];
	}
	
	return YES;
}

- (void)formViewController:(FormViewController *)formViewController didSelectRow:(NSDictionary *)formfieldDictionary
{
	if ([formViewController.formName isEqualToString:@"ChangePassword"])
	{
		if ([[formfieldDictionary valueForKey:@"Type"] isEqualToString:@"Button"])
		{
			if ([[formfieldDictionary valueForKey:@"Name"] isEqualToString:@"ChangeButton"])
			{
				[self saveAction];
			}
		}
	}
}


#pragma mark - Helper Functions

- (NSString *)buildJSONStringForRegistrationWithDictionary:(NSDictionary *)theDictionary
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:theDictionary];
	
	[dict setValue:[[[GlobusController sharedInstance] loggedUser] password] forKey:@"pwd"];
	[dict setValue:[[[GlobusController sharedInstance] loggedUser] email] forKey:@"Email"];
	[dict setValue:nil forKey:@"NewEmail"];
	[dict removeObjectForKey:@"newPwdConfirm"];
	
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
	NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	
	return jsonString;
}

- (void)storeNewUserData {
    User *loggedUser = [[GlobusController sharedInstance] loggedUser];
    if(loggedUser)
    {
		[loggedUser setValue:[self formfieldValueForName:@"newPwd"] forKey:@"password"];
	}
	
    [[GlobusController sharedInstance] setLoggedUser:loggedUser];
    [[ManagedUser sharedInstance] saveCurrentUserProfile];
}


#pragma mark - ABWebservice delegates

- (void)webserviceWillStart:(ABWebservice *)theWebservice
{
	//do nothing
}

- (void)webservice:(ABWebservice *)theWebservice didFinishWithObject:(id)theObject
{
	if (theWebservice == changePasswordJSONReader)
	{
		[[GlobusController sharedInstance] alertWithType:@"ChangePassword" messageKey:@"PasswordChanged"];
		[self storeNewUserData];		
	} 
    [self goBackToProfileVC];
}

- (void)webservice:(ABWebservice *)theWebservice didFailWithError:(NSError *)theError
{
	if (theWebservice == changePasswordJSONReader)
	{
		if (theError.code == -1012)
		{
			[[GlobusController sharedInstance] alertWithType:@"ChangePassword" messageKey:@"WrongConfirmPassword"];
		} else
		{
			[[GlobusController sharedInstance] alertWithType:@"ChangePassword" message:NSLocalizedString(@"All.ConnectErrorText", @"")];
		}
	}
}


#pragma mark - WebserviceWithAuthDataSource

- (NSString*)username {
    return [[[GlobusController sharedInstance] loggedUser] email];
}

- (NSString*)password {
    return [[[GlobusController sharedInstance] loggedUser] password];
}

#pragma mark - Bar Buttons methods

- (void)cancelButtonTouched {
	[[GlobusController sharedInstance] analyticsTrackEvent:@"ChangePassword" action:@"Cancel" label:@"ChangePassword" value:@0];
    [self goBackToProfileVC];
}

- (void)goBackToProfileVC {
    UIViewController *profileVC = nil;
    for(UIViewController *vc in self.navigationController.viewControllers) {
        if([[vc class] isEqual:[ProfileViewController class]]) {
            profileVC = vc;
            break;
        }
    }
    if(profileVC) {
        [self.navigationController popToViewController:profileVC animated:YES];
    }
}

@end

