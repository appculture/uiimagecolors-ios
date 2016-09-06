//
//  RegistrationFormViewController.m
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "GlobusController.h"
#import "RegistrationFormViewController.h"
#import "StylesheetController.h"
#import "UserResult.h"
#import "ResultStatus.h"
#import "UICellBackgroundView.h"
#import "BorderedView.h"
#import "BorderedButtonController.h"
#import "SystemUserSingleton.h"
#import "User.h"

@interface RegistrationFormViewController ()

@property (nonatomic) BOOL termsAndConditonsAccepted;
@property (nonatomic) BOOL noHouseNumber;

- (void)formfieldDidChangeNotification:(NSNotification *)theNotification;

- (void)formFirstFieldFocus;
- (void)errorHandlerShowWithError:(NSError *)theError;

- (NSString *)buildJSONStringForRegistrationWithDictionary:(NSDictionary *)theDictionary;

- (BOOL)checkForNumbersInString:(NSString *)theString;

@end

@implementation RegistrationFormViewController

@synthesize termsViewController = _termsViewController;
@synthesize termsAndConditonsAccepted = _termsAndConditonsAccepted;
@synthesize noHouseNumber = _noHouseNumber;

#pragma mark - Housekeeping

- (id)initWithCoder:(NSCoder *)theDecoder
{
	if ((self = [super initWithCoder:theDecoder]))
	{
        
		createUserJSONReader = [[CreateUserJSONReader alloc] init];
		createUserJSONReader.delegate = self;
        createUserJSONReader.dataSource = [SystemUserSingleton sharedInstance];
		
		checkLoginJSONReader = [[CheckLoginJSONReader alloc] init];
		checkLoginJSONReader.delegate = self;
        checkLoginJSONReader.dataSource = [SystemUserSingleton sharedInstance];
		
		checkGlobusCardJSONReader = [[CheckGlobusCardJSONReader alloc] init];
		checkGlobusCardJSONReader.delegate = self;
        checkGlobusCardJSONReader.dataSource = [SystemUserSingleton sharedInstance];
		
		_noHouseNumber = NO;
		
		[self setFormfieldValue:@"2080" forName:@"Globus_Card"];
	}
	
	return self;
}


#pragma mark - GUI startup & shutdown

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if (!formDictionary)
	{
		[super loadFormWithName:@"RegistrationForm"];
        
        BorderedView *cancelButton = [[BorderedButtonController sharedInstance] createBorderedViewWithName:@"CancelButton"];
        [[BorderedButtonController sharedInstance] registerTarget:self andAction:@selector(cancelAction) forBorderedView:cancelButton];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
		
		// Notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidAcceptTermsAndConditions:) name:UserDidAcceptTermsNotification object:nil];
		_termsAndConditonsAccepted = NO;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formfieldDidChangeNotification:) name:FormfieldDidChangeNotification object:nil];
	
	[infoView hideAnimated:NO];
	
	//When Card Available should be checked at the beginning
	//[self setFormfieldValue:@"YES" forName:@"CardAvailable"];	
	
	[self reloadForm];
	
	self.pageName = @"register";
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
	[createUserJSONReader stop];
	[checkLoginJSONReader stop];
	[checkGlobusCardJSONReader stop];
	_termsAndConditonsAccepted = NO;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UserDidAcceptTermsNotification object:nil];
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
		
	if ([[formfieldDictionary valueForKey:@"Type"] isEqualToString:@"Picker"])
		cell.userInteractionEnabled = YES;
	
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
    if ([[formfieldDictionary valueForKey:@"Name"] isEqualToString:@"Globus_Card"]){
        UICellBackgroundView *bgView = (UICellBackgroundView*)cell.backgroundView;
        bgView.position = UICellBackgroundViewPositionBottom;
    }
	
	if ([[formfieldDictionary valueForKey:@"Name"] isEqualToString:@"Terms"]){
		if (_termsAndConditonsAccepted) 
        {
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }	
	}
	
	return cell;
}

- (BOOL)formViewControllerShouldSave:(FormViewController *)formViewController
{
	if ([self hasMissingRequiredFormfields] || !_termsAndConditonsAccepted)
	{
		if ([formViewController.formName isEqualToString:@"Registration"])
			[[GlobusController sharedInstance] alertWithType:@"Registration" messageKey:@"IncorrectRegistration"];
		
		return NO;
	}
		
	if ([formViewController.formName isEqualToString:@"Registration"])
	{
		
		BOOL isValid = NO;
		
		if (![[self formfieldValueForName:@"Email"] isEqualToString:[self formfieldValueForName:@"EmailConfirm"]])
		{
			[[GlobusController sharedInstance] alertWithType:@"Registration" messageKey:@"WrongConfirmEmail"];
			[self setFormfieldValue:nil forName:@"EmailAddressConfirm"];
			[self setFormfieldValue:nil forName:@"pwd"];
			[self setFormfieldValue:nil forName:@"pdwConfirm"];
		}
		else if ([self formfieldValueForName:@"pwd"].length < 6)
		{
			[[GlobusController sharedInstance] alertWithType:@"Registration" messageKey:@"PasswordToShort"];
			[self setFormfieldValue:nil forName:@"pwd"];
		}
		else if (![[self formfieldValueForName:@"pwd"] isEqualToString:[self formfieldValueForName:@"pwdConfirm"]])
		{
			[[GlobusController sharedInstance] alertWithType:@"Registration" messageKey:@"WrongConfirmPassword"];
			[self setFormfieldValue:nil forName:@"pwdConfirm"];
		}
		else if ([self checkForNumbersInString:[self formfieldValueForName:@"Name"]])
		{
			[[GlobusController sharedInstance] alertWithType:@"Registration" messageKey:@"NumberInLastName"]; 
		}
		else if ([self checkForNumbersInString:[self formfieldValueForName:@"Vorname"]])
		{
			[[GlobusController sharedInstance] alertWithType:@"Registration" messageKey:@"NumberInFirstName"]; 
		}
		else if ([self formfieldValueForName:@"StrassenNr"].length == 0 && !_noHouseNumber)
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert.Registration.TitleText", @"") message:NSLocalizedString(@"Alert.Registration.NoHousnumberAvailable.MessageText", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"All.YesText", @"") otherButtonTitles:NSLocalizedString(@"All.NoText", @""), nil];
			alert.tag = 5;
			[alert show];
		}
		else if ([[self formfieldValueForName:@"CardAvailable"] boolValue] && [[self formfieldValueForName:@"Globus_Card"] length] < 13)
		{
			[[GlobusController sharedInstance] alertWithType:@"Registration" message:NSLocalizedString(@"ValidationErrorCodes.INVALID.Globus_Card", @"")];
		}
		else
		{
			isValid = YES;
		}
		if (!isValid)
		{
			return NO;
		}
		
		_noHouseNumber = NO;
		
		NSString *crcString;
		if ([[valueDictionary valueForKey:@"crc"] length] > 0)
		{
			crcString = [valueDictionary valueForKey:@"crc"];
		}
		
		NSString *jsonString = [self buildJSONStringForRegistrationWithDictionary:valueDictionary];
		
		NSString *lang = NSLocalizedString(@"All.LanguageCode", @"");
		
		if ([lang isEqualToString:@"en"])
		{
			if ([[valueDictionary valueForKey:@"Sprache"] isEqualToString:@"F"])
				lang = @"fr";
			else
				lang = @"de";
		}
		
		[[GlobusController sharedInstance] analyticsTrackEvent:@"Register" action:@"Click" label:@"Register" value:@0];
		
		[createUserJSONReader createUser:jsonString crc:crcString lang:lang];
	}
	
	return NO;
}

- (BOOL)formViewController:(FormViewController *)formViewController shouldDisplayFormfield:(NSDictionary *)formfieldDictionary
{
	if ([formViewController.formName isEqualToString:@"Registration"])
	{
		BOOL cardAvailableEnabled = [[self formfieldValueForName:@"CardAvailable"] boolValue];
		
		NSString *name = [formfieldDictionary valueForKey:@"Name"];
		if (name && !cardAvailableEnabled && [name isEqualToString:@"Globus_Card"])
			return NO;
		if (name && !cardAvailableEnabled && [name isEqualToString:@"crc"])
			return NO;
	}
	
	return YES;
}

- (void)formViewController:(FormViewController *)formViewController didSelectRow:(NSDictionary *)formfieldDictionary
{
	if ([formViewController.formName isEqualToString:@"Registration"])
	{
		if ([[formfieldDictionary valueForKey:@"Type"] isEqualToString:@"Button"])
		{
			if ([[formfieldDictionary valueForKey:@"Name"] isEqualToString:@"RegistrationButton"])
			{
				[self saveAction];
			}
			if ([[formfieldDictionary valueForKey:@"Name"] isEqualToString:@"Terms"])
			{
				[self.navigationController pushViewController:_termsViewController animated:YES];
			}
		}
	}
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

- (void)formViewControllerDidCancel:(FormViewController *)theFormViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelAction
{
	[[GlobusController sharedInstance] analyticsTrackEvent:@"Register" action:@"Cancel" label:@"Register" value:@0];
	
	[super cancelAction];
	
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Helper functions

- (void)formFirstFieldFocus
{
	if ([self.formName isEqualToString:@"Login"] || [self.formName isEqualToString:@"OrderLogin"])
	{
		if ([self formfieldValueForName:@"Email"].length > 0)
			[self focusForFormfieldName:@"pwd"];
		else
			[self focusForFormfieldName:@"Email"];
	}
	else if ([self.formName isEqualToString:@"pwdReset"])
		[self focusForFormfieldName:@"Email"];
}

- (void)errorHandlerShowWithError:(NSError *)theError
{
	[self formFirstFieldFocus];
}

- (NSString *)buildJSONStringForRegistrationWithDictionary:(NSDictionary *)theDictionary
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:theDictionary];
	[dict removeObjectForKey:@"EmailConfirm"];
	[dict removeObjectForKey:@"pwdConfirm"];
	
	//change format from date
	NSString *dateString = [dict objectForKey:@"Geburtsdatum"];
	[dict setValue:[[GlobusController sharedInstance] englishDateStringFromGermanDateString:dateString] forKey:@"Geburtsdatum"];
	
//	NSString *lang = NSLocalizedString(@"All.LanguageCode", @"");
//	
//	if ([lang isEqualToString:@"en"])
//		lang = @"de";
//	
//	[dict setValue:lang forKey:@"lang"];
//	
	BOOL cardAvailableEnabled = [[self formfieldValueForName:@"CardAvailable"] boolValue];
	if (!cardAvailableEnabled)
	{
		[dict removeObjectForKey:@"Globus_Card"];
		[dict removeObjectForKey:@"crc"];
	} else {
		NSString *globusCardValue = [self.valueDictionary valueForKey:@"Globus_Card"];
		NSString *step1 = [globusCardValue substringFromIndex:4]; 
		NSString *customerNumber = [step1 substringToIndex:8];
		
		[dict setValue:customerNumber forKey:@"Globus_Card"];
		[dict removeObjectForKey:@"crc"];
	}
	
	[dict removeObjectForKey:@"CardAvailable"];
	
	NSError *error = nil;
//	NSData *jsonData = [[CJSONSerializer serializer] serializeDictionary:dict error:&error];
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
	NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
		
	return jsonString;
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


#pragma mark - Alerts

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 5)
	{
		if (buttonIndex == 1)
		{	
			_noHouseNumber = YES;
			BOOL shouldSave = [self formViewControllerShouldSave:self];
            if(shouldSave) {
                
            }
		}
	} else {
		if (buttonIndex == 1)
			[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	}
}


#pragma mark - Notifications

- (void)formfieldDidChangeNotification:(NSNotification *)theNotification
{
	NSDictionary *formfieldDictionary = (NSDictionary *)theNotification.object;
	NSString *name = [formfieldDictionary valueForKey:@"Name"];
	
	if ([name isEqualToString:@"CardAvailable"]) {
		[self endEditing];
		
		FormfieldCell *switchCell = [self formfieldCellForName:@"CardAvailable"];
        UICellBackgroundView *bgView = (UICellBackgroundView*)switchCell.backgroundView;
        bgView.position = bgView.position == UICellBackgroundViewPositionSingle ? UICellBackgroundViewPositionTop : UICellBackgroundViewPositionSingle;
        [self reloadFormAnimated];
    }
	else if ([name isEqualToString:@"Globus_Card"] || [name isEqualToString:@"crc"])
	{
		NSString *globusCardValue = [self.valueDictionary valueForKey:@"Globus_Card"];
		NSString *crcValue = [self.valueDictionary valueForKey:@"crc"];
		if (globusCardValue.length == 13 && crcValue.length == 4)
		{
			[checkGlobusCardJSONReader checkGlobusCard:globusCardValue crc:crcValue];
		}
		else
			[checkGlobusCardJSONReader stop];
		
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
	if (theWebservice == createUserJSONReader)
	{
		ResultStatus *result = (ResultStatus *)theObject;
		
		
		if (result.isValidationError)
		{
			[[GlobusController sharedInstance] alertWithType:@"Registration" message:result.errorMessage];
		} else
		{
			if (result.isErrorMessage)
			{
				[[GlobusController sharedInstance] alertWithType:@"Registration" message:[result.errorMessages objectAtIndex:0]];
			} else
			{
				[[GlobusController sharedInstance] alertWithType:@"Registration" messageKey:@"UserCreated"];
				[self setValueDictionary:nil];
				[self.navigationController dismissViewControllerAnimated:YES completion:nil];
			}
		}
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
				[[GlobusController sharedInstance] alertWithType:@"Registration" messageKey:@"UsernameExists"];
				[self setFormfieldValue:nil forName:@"Email"];
				[self setFormfieldValue:nil forName:@"EmailConfirm"];
				[self focusForFormfieldName:@"Email"];
			}
		} else
		{
			BOOL isAssignableAndValid = [(NSString *)theObject boolValue];
			
			if (!isAssignableAndValid)
			{
				[[GlobusController sharedInstance] alertWithType:@"Registration" messageKey:@"NotAssignableOrNotValid"];
				[self focusForFormfieldName:@"Globus_Card"];
			} else 
			{
				[[GlobusController sharedInstance] alertWithType:@"Registration" messageKey:@"AssignableAndValid"];
			}

		}		
	}
}

- (void)webservice:(ABWebservice *)theWebservice didFailWithError:(NSError *)theError
{
	if (theWebservice == createUserJSONReader)
	{
        if(!theError) {
            
        }
        
        if(theError.code == -1012){
            [[GlobusController sharedInstance] alertWithType:@"Register" messageKey:@"WrongUsernameOrPassword"];
        } else if (theError.code == -1004  || theError.code == -1009) {
            [[GlobusController sharedInstance] alertWithType:@"Register" message:NSLocalizedString(@"All.ConnectErrorText", @"")];
        }
	}
}


#pragma mark - Nofications

- (void)userDidAcceptTermsAndConditions:(NSNotification *)theNotification
{
    _termsAndConditonsAccepted = YES;    
    [tableView reloadData];
}

@end

