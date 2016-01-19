//
//  ProfileViewController.m
//  Globus
//
//  Created by Mladen Djordjevic on 3/2/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "ProfileViewController.h"
#import "SingleTextCell.h"
#import "UICellBackgroundView.h"
#import "GlobusController.h"
#import "User.h"
#import "StylesheetController.h"
#import "InputFormfieldCell.h"
#import "ManagedUser.h"
#import "BorderedView.h"
#import "BorderedButtonController.h"
#import "CouponsController.h"

@interface ProfileViewController()

@property (nonatomic, strong) NSString *viewControllerToPresentName;

-(void)backBtnTouched;

@end

@implementation ProfileViewController

@synthesize loginNC = _loginNC;
@synthesize loginVC = _loginVC;
@synthesize viewControllerToPresentName = _viewControllerToPresentName;
@synthesize changeEmailVC = _changeEmailVC;
@synthesize changePasswordVC = _changePasswordVC;
@synthesize editProfileVC = _editProfileVC;


- (id)initWithCoder:(NSCoder *)theDecoder
{
	if (self = [super initWithCoder:theDecoder])
	{
    
	}
	
	return self;
}


#pragma mark - GUI startup & shutdown

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if (!formDictionary)
	{
		[super loadFormWithName:@"ProfileForm"];
		
		// customize tableview
		tableView.sectionFooterHeight = 0.0;
        
       	self.delegate = self;
        [(LoginFormViewController*)_loginVC setFormDelegate:self];
        [(LoginFormViewController*)_loginVC setDelegate:self];
		
		[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setFormDelegate:self];
		
        BorderedView *backButton = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"BackButton"];
        backButton.touchTreshold = 10;
        [[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(backBtnTouched) forBorderedView:backButton];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	User *currentUser = [[GlobusController sharedInstance] loggedUser];
	[self setFormfieldValue:currentUser.email forName:@"Email" updateCell:YES];
	[self setFormfieldValue:[currentUser.customerNumber description] forName:@"GlobusCard" updateCell:YES];
	
	NSString *reminder = nil;
	if ([[GlobusController sharedInstance] isReminderActivated])
		reminder = @"YES";
	else
		reminder = @"NO";
	[self setFormfieldValue:reminder forName:@"ReminderSwitch" updateCell:YES];

 	NSString *push = nil;
	if ([[GlobusController sharedInstance] pushNotificationsEnabled])
		push = @"YES";
	else
		push = @"NO";
	[self setFormfieldValue:push forName:@"PushSwitch" updateCell:YES];
   
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formfieldDidChangeNotification:) name:FormfieldDidChangeNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(globusControllerStartLoginNotification:) name:GlobusControllerStartLoginNotification object:nil];
	
	self.pageName = @"myaccount";
	[[GlobusController sharedInstance] analyticsTrackPageview:[self.navigationController pagePath]];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GlobusControllerStartLoginNotification object:nil]; 
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FormfieldDidChangeNotification object:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
	else
		return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Overwritting super class methods

- (NSString *)formViewController:(FormViewController *)theFormViewController titleForFooterForFormfieldGroup:(NSDictionary *)formfieldGroupDictionary
{
	NSString *name = [formfieldGroupDictionary valueForKey:@"Name"];
	
	if (name && [name isEqualToString:@"PushGroup"])
		return [[GlobusController sharedInstance] pushNotificationsEnabled] ? NSLocalizedString(@"Profile.PushEnabledInformationText", @"") : NSLocalizedString(@"Profile.PushDisabledInformationText", @"");
	
	return [super formViewController:theFormViewController titleForFooterForFormfieldGroup:formfieldGroupDictionary];
}

- (void)formViewControllerDidCancel:(FormViewController *)theFormViewController {

    if(![theFormViewController.formName isEqualToString:@"Login"]){
        [self.navigationController popViewControllerAnimated:YES];
    }
//    NSLog(@"theFormViewController.formName: %@",theFormViewController.formName);
//    if([theFormViewController.formName isEqualToString:@"Profile"]){
//        [self.navigationController popViewControllerAnimated:YES];
//    } else if([theFormViewController.formName isEqualToString:@"Login"]){
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
    
}

//- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
//}

- (void)formfieldDidChangeNotification:(NSNotification *)theNotification
{
	NSDictionary *formfieldDictionary = (NSDictionary *)theNotification.object;
	NSString *name = [formfieldDictionary valueForKey:@"Name"];
	
	if ([name isEqualToString:@"ReminderSwitch"])
	{
		BOOL value =  [[valueDictionary valueForKey:name] boolValue];
		NSString *valueString = value ? @"YES" : @"NO";
		NSString *trackingString = value ? @"On" : @"Off";
		[[NSUserDefaults standardUserDefaults] setObject:valueString forKey:@"isReminderActivated"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[[GlobusController sharedInstance] setIsReminderActivated:value];
		
		[[CouponsController sharedInstance] setAlarmsForCoupons];
		
		[[GlobusController sharedInstance] analyticsTrackEvent:@"MyAccount" action:trackingString label:@"Reminder" value:@0];
	}
}


- (BOOL)formViewControllerShouldSave:(FormViewController *)formViewController
{
    return YES;
    
}



- (void)formViewController:(FormViewController *)formViewController didSelectRow:(NSDictionary *)formfieldDictionary
{
    NSIndexPath *indexPath = [formViewController indexPathForFormfieldWithName:[formfieldDictionary valueForKey:@"Name"]];
    [formViewController.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([[formfieldDictionary valueForKey:@"Name"] isEqualToString:@"ChangeEmailBtn"]) {
		[(LoginFormViewController*)_loginVC setTrackingName:@"changemaillogin"];
		[(LoginFormViewController*)_loginVC setTrackingCategory:@"ChangeMailLogin"];
        [self.navigationController pushViewController:_loginVC animated:YES];
        _viewControllerToPresentName = @"ChangeEmailFormViewController";
    } else if([[formfieldDictionary valueForKey:@"Name"] isEqualToString:@"ChangePasswordBtn"]){
		[(LoginFormViewController*)_loginVC setTrackingName:@"changepasswordlogin"];
		[(LoginFormViewController*)_loginVC setTrackingCategory:@"ChangePasswordLogin"];
        [self.navigationController pushViewController:_loginVC animated:YES];
        _viewControllerToPresentName = @"ChangePasswordFormViewController";
    } else if([[formfieldDictionary valueForKey:@"Name"] isEqualToString:@"EditProfileBtn"]){
        [self.navigationController pushViewController:_editProfileVC animated:YES];
    }
}

#pragma mark - LoginFormController delegate methods

- (void)controllerDidFinishDismissAnimation {
    if([_viewControllerToPresentName isEqualToString:@"ChangeEmailFormViewController"]){
        _changeEmailVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.navigationController pushViewController:_changeEmailVC animated:YES];
    } else
	{
		 if([_viewControllerToPresentName isEqualToString:@"ChangePasswordFormViewController"]){
			 _changePasswordVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
			 [self.navigationController pushViewController:_changePasswordVC animated:YES];
		 }
	}
}
- (void)userDidLogIn {
    
}

- (void)userDidFailToLogInWithError:(NSError*)error {
//    if([error code] == -1012){
//        [[GlobusController sharedInstance] setLoggedUser:[[ManagedUser sharedInstance] userData]];
//        [[GlobusController sharedInstance] alertWithType:@"Login" messageKey:@"WrongUsernameOrPassword"];
//    }
}

-(void)backBtnTouched {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Notifications

- (void)globusControllerStartLoginNotification:(NSNotification *)theNotification
{
	[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setTrackingName:@"login"];
	[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setTrackingCategory:@"Login"];
	[self.navigationController presentViewController:_loginNC animated:YES completion:nil];
}


@end
