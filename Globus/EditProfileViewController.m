//
//  EditProfileViewController.m
//  Globus
//
//  Created by Mladen Djordjevic on 3/15/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "EditProfileViewController.h"
#import "GlobusController.h"
#import "WebserviceWithAuth.h"
#import "User.h"
#import "ProfileUpdateJSONReader.h"
#import "BorderedView.h"
#import "BorderedButtonController.h"
#import "ManagedUser.h"

@interface EditProfileViewController() 

@property (nonatomic, strong) ProfileUpdateJSONReader *profileUpdateJSONReader;
@property (nonatomic, strong) BorderedView *saveButton;

- (void)initObject;
- (NSString *)buildJSONStringForRegistrationWithDictionary:(NSDictionary *)theDictionary;
- (void)backButtonAction;
- (void)saveButtonAction;
- (void)storeNewUserData;
- (BOOL)checkForNumbersInString:(NSString *)theString;

@end


@implementation EditProfileViewController

@synthesize profileUpdateJSONReader = _profileUpdateJSONReader;
@synthesize saveButton = _saveButton;
@synthesize loginNC = _loginNC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initObject];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (id)initWithCoder:(NSCoder *)theDecoder
{
	if ((self = [super initWithCoder:theDecoder]))
	{
		[self initObject];
	}
	
	return self;
}
- (void)initObject {
    _profileUpdateJSONReader = [[ProfileUpdateJSONReader alloc] init];
    _profileUpdateJSONReader.delegate = self;
    _profileUpdateJSONReader.dataSource = self;
    _profileUpdateJSONReader.statusCodesDataSource = self;
    
}


#pragma mark - GUI startup & shutdown

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if (!formDictionary)
	{
		[super loadFormWithName:@"EditProfileForm"];
        self.delegate = self;
        
        BorderedView *backButton = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"BackButton"];
        backButton.touchTreshold = 10;
        [[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(backButtonAction) forBorderedView:backButton];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        BorderedView *saveButton = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"SaveButton"];
        [[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(saveButtonAction) forBorderedView:saveButton];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
        self.saveButton = saveButton;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formfieldDidChangeNotification:) name:FormfieldDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(globusControllerStartLoginNotification:) name:GlobusControllerStartLoginNotification object:nil];
	
	[infoView hideAnimated:NO];
    
    User *loggedUser = [[GlobusController sharedInstance] loggedUser];
    if(loggedUser)
    {
        for(NSDictionary *section in formfieldArray)
        {
            NSArray *rowArray = [section objectForKey:@"Rows"];
            
            for(NSDictionary *row in rowArray)
            {
				NSString *formName = [row objectForKey:@"Name"];
                NSString *coreDataName = [[GlobusController sharedInstance] getCoreDataNameForFormName:formName];
				
                if(coreDataName && [loggedUser valueForKey:coreDataName])
                {
                    NSString *value = nil;
                    if([[[loggedUser valueForKey:coreDataName] class] isSubclassOfClass:[NSDate class]]){
                        value = [[GlobusController sharedInstance] dateStringFromDate:[loggedUser valueForKey:coreDataName]];
                        
                    } else if([[[loggedUser valueForKey:coreDataName] class] isSubclassOfClass:[NSNumber class]]){
                        value = [[loggedUser valueForKey:coreDataName] description];
                    } else {
                        value = [loggedUser valueForKey:coreDataName];
                    }
                    if(value) {
                        [self setFormfieldValue:value forName:formName];
                    }
                }
            } 
        } 
    }
	
	[self reloadForm];
    _saveButton.userInteractionEnabled = NO;
	
	self.pageName = @"profile";
	[[GlobusController sharedInstance] analyticsTrackPageview:[self.navigationController pagePath]];
}
- (void)storeNewUserData {
    User *loggedUser = [[GlobusController sharedInstance] loggedUser];
    if(loggedUser)
    {
        for(NSDictionary *section in formfieldArray)
        {
            NSArray *rowArray = [section objectForKey:@"Rows"];
            
            for(NSDictionary *row in rowArray)
            {
				NSString *formName = [row objectForKey:@"Name"];
                NSString *coreDataName = [[GlobusController sharedInstance] getCoreDataNameForFormName:formName];
				
                if(loggedUser && [self valueForFormfieldCell:[self formfieldCellForName:formName]])
                {
                    id value = nil;
                    if([[[loggedUser valueForKey:coreDataName] class] isSubclassOfClass:[NSDate class]] || [coreDataName isEqualToString:@"birthDate"]){
                        if([[[self valueForFormfieldCell:[self formfieldCellForName:formName]] class] isSubclassOfClass:[NSDate class]]) {
                            value = [self valueForFormfieldCell:[self formfieldCellForName:formName]];
                        } else {
                            value = [[GlobusController sharedInstance] dateFromGermanDateString:[self valueForFormfieldCell:[self formfieldCellForName:formName]]];
                        }
                        
                    } else if([[[loggedUser valueForKey:coreDataName] class] isSubclassOfClass:[NSNumber class]]){
                        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                        [f setNumberStyle:NSNumberFormatterDecimalStyle];
                        value = [f numberFromString:[self valueForFormfieldCell:[self formfieldCellForName:formName]]];
                    } else {
                        value = [self valueForFormfieldCell:[self formfieldCellForName:formName]];
                    }
                    
                    [loggedUser setValue:value forKey:coreDataName];
                    
                }
            } 
        } 
    }
    [[GlobusController sharedInstance] setLoggedUser:loggedUser];
    [[ManagedUser sharedInstance] saveCurrentUserProfile];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GlobusControllerStartLoginNotification object:nil]; 
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
    [_profileUpdateJSONReader stop];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:FormfieldDidChangeNotification object:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
	else
		return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Overwritting super class methods

- (void)formViewControllerDidSave:(FormViewController *)formViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)formViewControllerDidCancel:(FormViewController *)theFormViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)formViewControllerShouldSave:(FormViewController *)formViewController
{
	return YES;
}

-(FormfieldCell*)formViewController:(FormViewController *)theFormViewController cellForFormfield:(NSDictionary *)formfieldDictionary 
{
    FormfieldCell *cell;
	
	cell = [super formViewController:theFormViewController cellForFormfield:formfieldDictionary];
	
	if ([[formfieldDictionary valueForKey:@"Type"] isEqualToString:@"Picker"])
		cell.userInteractionEnabled = YES;

	return cell;
}

- (BOOL)formViewController:(FormViewController *)formViewController shouldDisplayFormfield:(NSDictionary *)formfieldDictionary
{
	return YES;
}

- (BOOL)hasMissingRequiredFormfields
{
	for (NSDictionary *sectionDictionary in formfieldArray)
		for (NSDictionary *rowDictionary in [sectionDictionary objectForKey:@"Rows"])
		{
			NSString *name = [rowDictionary valueForKey:@"Name"];
			NSString *required = [rowDictionary valueForKey:@"Required"];
            int length = 0;
            if([[valueDictionary valueForKey:name] respondsToSelector:@selector(length)]){
                length = [[valueDictionary valueForKey:name] length];
            } else {
                if([[[[valueDictionary valueForKey:name] class] description] isEqualToString:@"__NSDate"]){
                    length = [[[GlobusController sharedInstance] dateStringFromDate:[valueDictionary objectForKey:name]] length];
                }
            }
			if (required && [required boolValue] && length == 0)
				return YES;
		}
	
	return NO;
}

#pragma mark - Helper functions

- (NSString *)buildJSONStringForRegistrationWithDictionary:(NSDictionary *)theDictionary
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:valueDictionary];
	
	//change format from date
    id dateObj = [dict objectForKey:@"Geburtsdatum"];
	NSString *dateString = nil;
    if([[[dateObj class] description] isEqualToString:@"__NSDate"]){
        dateString = [[GlobusController sharedInstance] dateStringFromDate:dateObj];
    } else {
        dateString = dateObj;
    }
	[dict setValue:[[GlobusController sharedInstance] englishDateStringFromGermanDateString:dateString] forKey:@"Geburtsdatum"];
	
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
	NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
	return jsonString;
}

#pragma mark - Notifications

- (void)formfieldDidChangeNotification:(NSNotification *)theNotification
{
    if(!_saveButton.userInteractionEnabled) {
        _saveButton.userInteractionEnabled = YES;
    }
//	NSDictionary *formfieldDictionary = (NSDictionary *)theNotification.object;
//	NSString *name = [formfieldDictionary valueForKey:@"Name"];
	
}

#pragma mark - ABWebservice delegates

- (void)webserviceWillStart:(ABWebservice *)theWebservice
{
	//do nothing
}

- (void)webservice:(ABWebservice *)theWebservice didFinishWithObject:(id)theObject
{
    if([theObject respondsToSelector:@selector(objectForKey:)]){
        NSError *error = [[GlobusController sharedInstance] checkIfThereIsValidationAndSecurityErrorsForDic:theObject];
        if(!error) {
            [[GlobusController sharedInstance] alertWithType:@"EditProfile" messageKey:@"ProfileUpdated"];
            [self.navigationController popViewControllerAnimated:YES];
            [self storeNewUserData];
        } else {
            NSString *errorDesc = [error.userInfo objectForKey:kErrorDesc];
            [[GlobusController sharedInstance] alertWithType:@"EditProfile" message:errorDesc];
			
			if (error.code == -5003)
			{
				[[NSNotificationCenter defaultCenter] postNotificationName:GlobusControllerStartLoginNotification object:nil];
			}
        }
    }
    
    //TO-DO implementation
}

- (void)webservice:(ABWebservice *)theWebservice didFailWithError:(NSError *)theError
{
	if (theError.code == -1004  || theError.code == -1009 || theError.code == -1005 || !theError) {
		[[GlobusController sharedInstance] setLoggedUser:[[ManagedUser sharedInstance] userData]];
		[[GlobusController sharedInstance] alertWithType:@"EditProfile" message:NSLocalizedString(@"All.ConnectErrorText", @"")];
	} else if (theError.code == -1012) {
		[[GlobusController sharedInstance] setLoggedUser:[[ManagedUser sharedInstance] userData]];
		[[NSNotificationCenter defaultCenter] postNotificationName:GlobusControllerStartLoginNotification object:nil];
	}
}

#pragma mark - WebserviceAuthDataSource methods

- (NSString*)username {
    return [[[GlobusController sharedInstance] loggedUser] email];
}
- (NSString*)password {
    return [[[GlobusController sharedInstance] loggedUser] password];
}

#pragma mark - WebserviceValidDataSource methods

- (NSArray*)webserviceValidStatusCodesArray{
    NSArray *validCodes = [NSArray arrayWithObjects:[NSNumber numberWithInt:204],[NSNumber numberWithInt:400],[NSNumber numberWithInt:401], nil];
    return validCodes;
}

#pragma mark - Bar Buttons actions

- (void)backButtonAction {
	[[GlobusController sharedInstance] analyticsTrackEvent:@"Profile" action:@"Cancel" label:@"Profile" value:@0];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)saveButtonAction {
    if ([self hasMissingRequiredFormfields])
	{
        [[GlobusController sharedInstance] alertWithType:@"EditProfile" messageKey:@"IncorrectProfileUpdate"]; 
        return;
	}
	
	if ([self checkForNumbersInString:[self formfieldValueForName:@"Name"]])
	{
		[[GlobusController sharedInstance] alertWithType:@"EditProfile" messageKey:@"NumberInLastName"]; 
        return;
	}
	if ([self checkForNumbersInString:[self formfieldValueForName:@"Vorname"]])
	{
		[[GlobusController sharedInstance] alertWithType:@"EditProfile" messageKey:@"NumberInFirstName"]; 
        return;
	}
	
	if ([self.formName isEqualToString:@"EditProfile"])
	{
        [[GlobusController sharedInstance] analyticsTrackEvent:@"Profile" action:@"Save" label:@"Profile" value:@0];
		
		NSString *jsonString = [self buildJSONStringForRegistrationWithDictionary:valueDictionary];
		
		[_profileUpdateJSONReader updateUserDataWithUserJSON:jsonString];
	}
	
}

- (BOOL)checkForNumbersInString:(NSString *)theString
{
	NSError *error = nil;
    
    NSString *regexString = [NSString stringWithFormat:@"\\D"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:&error];
    NSArray *matches = [regex matchesInString:theString options:0 range:NSMakeRange(0, [theString length])];
    if([matches count] == [theString length]) {
        return NO;
    }
    return YES;
}


#pragma mark - Notifications

- (void)globusControllerStartLoginNotification:(NSNotification *)theNotification
{
	[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setTrackingName:@"login"];
	[(LoginFormViewController*)[_loginNC.viewControllers objectAtIndex:0] setTrackingCategory:@"Login"];
	[self.navigationController presentViewController:_loginNC animated:YES completion:nil];
}

@end
