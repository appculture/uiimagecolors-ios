//
//  ChangeEmailFormViewController.m
//  Globus
//
//  Created by Mladen Djordjevic on 3/14/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "ChangeEmailFormViewController.h"
#import "GlobusController.h"
#import "User.h"
#import "BorderedButtonController.h"
#import "BorderedView.h"
#import "ProfileViewController.h"
#import "ManagedUser.h"
#import "SystemUserSingleton.h"

@interface ChangeEmailFormViewController ()

- (NSString *)buildJSONStringForRegistrationWithDictionary:(NSDictionary *)theDictionary;
- (void)cancelButtonTouched;
- (void)goBackToProfileVC;
- (void)storeNewUserData;

@end

@implementation ChangeEmailFormViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		changeEmailJSONReader = [[ChangeEmailJSONReader alloc] init];
		changeEmailJSONReader.delegate = self;
		changeEmailJSONReader.dataSource = self;
		
		checkLoginJSONReader = [[CheckLoginJSONReader alloc] init];
		checkLoginJSONReader.delegate = self;
        checkLoginJSONReader.dataSource = [SystemUserSingleton sharedInstance];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)theDecoder
{
	if (self = [super initWithCoder:theDecoder])
	{
        changeEmailJSONReader = [[ChangeEmailJSONReader alloc] init];
		changeEmailJSONReader.delegate = self;
		changeEmailJSONReader.dataSource = self;
		
		checkLoginJSONReader = [[CheckLoginJSONReader alloc] init];
		checkLoginJSONReader.delegate = self;
        checkLoginJSONReader.dataSource = [SystemUserSingleton sharedInstance];
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
		[super loadFormWithName:@"ChangeEmailForm"];
		
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
	
	self.pageName = @"changemail";
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
	
	[changeEmailJSONReader stop];
	[checkLoginJSONReader stop];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
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
	
	if ([[formfieldDictionary valueForKey:@"Name"] isEqualToString:@"Email"])
	{
		if (checkLoginJSONReader.running)
		{
			cell.userInteractionEnabled = NO;
			UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			[activityView startAnimating];
			cell.accessoryView = activityView;
		}
		else
			cell.userInteractionEnabled = YES;	
	}
	
	return cell;
}


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

- (void)formfieldCellDidEndEditing:(FormfieldCell *)formfieldCell
{
	[tableView deselectRowAtIndexPath:[tableView indexPathForCell:formfieldCell] animated:YES];
	
	if ([[formfieldCell.formfieldDictionary valueForKey:@"Name"] isEqualToString:@"Email"] && [self formfieldValueForName:@"Email"].length > 0)
	{
		[checkLoginJSONReader stop];
		[checkLoginJSONReader checkUsername:[self valueForFormfieldCell:formfieldCell]];
		[self reloadInputViews];
	}
}


- (BOOL)formViewControllerShouldSave:(FormViewController *)formViewController
{
	if ([self hasMissingRequiredFormfields])
	{
		if ([formViewController.formName isEqualToString:@"ChangeEmail"])
			[[GlobusController sharedInstance] alertWithType:@"ChangeEmail" messageKey:@"MissingFields"];
		
		return NO;
	}
	
	if ([formViewController.formName isEqualToString:@"ChangeEmail"])
	{
		if (![[self formfieldValueForName:@"Email"] isEqualToString:[self formfieldValueForName:@"ConfirmEmail"]])
		{
			[[GlobusController sharedInstance] alertWithType:@"ChangeEmail" messageKey:@"WrongConfirmEmail"];
			[self setFormfieldValue:nil forName:@"EmailAddressConfirm"];
			
			return NO;
		} else
		{
			BOOL emailValid = [[GlobusController sharedInstance] validateEmail:[self formfieldValueForName:@"Email"]];
			
			if (!emailValid)
			{
				[[GlobusController sharedInstance] alertWithType:@"ChangeEmail" messageKey:@"NotValidEmail"];
				[self setFormfieldValue:nil forName:@"EmailAddressConfirm"];
				
				return NO;
			}
		}
		
		[[GlobusController sharedInstance] analyticsTrackEvent:@"ChangeMail" action:@"Click" label:@"ChangeMail" value:@0];
				
		NSString *jsonString = [self buildJSONStringForRegistrationWithDictionary:valueDictionary];
		
		[changeEmailJSONReader changeEmailWithBody:jsonString];
	}

	return YES;
}

- (void)formViewController:(FormViewController *)formViewController didSelectRow:(NSDictionary *)formfieldDictionary
{
	if ([formViewController.formName isEqualToString:@"ChangeEmail"])
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


#pragma -
#pragma Helper Functions

- (NSString *)buildJSONStringForRegistrationWithDictionary:(NSDictionary *)theDictionary
{
	//NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:theDictionary];
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setValue:[[[GlobusController sharedInstance] loggedUser] password] forKey:@"pwd"];
	[dict setValue:[[[GlobusController sharedInstance] loggedUser] email] forKey:@"Email"];
	NSString *newMail = [[theDictionary valueForKey:@"Email"] lowercaseString];
	[dict setValue:newMail forKey:@"NewEmail"];
	
	
		
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
	NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	
	return jsonString;
}

- (void)storeNewUserData {
    User *loggedUser = [[GlobusController sharedInstance] loggedUser];
    if(loggedUser)
    {
		[loggedUser setValue:[self formfieldValueForName:@"Email"] forKey:@"email"];
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
	if (theWebservice == changeEmailJSONReader)
	{
		[[GlobusController sharedInstance] alertWithType:@"ChangeEmail" messageKey:@"EmailChanged"];
		[self storeNewUserData];
		
		[self goBackToProfileVC];
	} else
	{
		if (theWebservice == checkLoginJSONReader)
		{
			BOOL isUserExist = [(NSString *)theObject boolValue];
			
			if (!isUserExist)
			{
				[self reloadInputViews];
			} else
			{
				[[GlobusController sharedInstance] alertWithType:@"ChangeEmail" messageKey:@"UsernameExists"];
				[self setFormfieldValue:nil forName:@"Email"];
				[self setFormfieldValue:nil forName:@"EmailConfirm"];
				[self focusForFormfieldName:@"Email"];
			}
		}	
	}
}

- (void)webservice:(ABWebservice *)theWebservice didFailWithError:(NSError *)theError
{
	if (theWebservice == changeEmailJSONReader)
	{
		[[GlobusController sharedInstance] alertWithType:@"ChangeEmail" message:NSLocalizedString(@"All.ConnectErrorText", @"")];
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
	[[GlobusController sharedInstance] analyticsTrackEvent:@"ChangeMail" action:@"Cancel" label:@"ChangeMail" value:@0];
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

