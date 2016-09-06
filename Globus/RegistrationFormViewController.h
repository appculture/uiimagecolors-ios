//
//  RegistrationFormViewController.h
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import <UIKit/UIKit.h>
//#import "FormViewController.h"
#import "AddressBookUI/AddressBookUI.h"
#import "ABButton.h"
#import "CreateUserJSONReader.h"
#import "CheckLoginJSONReader.h"
#import "CheckGlobusCardJSONReader.h"
#import "CustomCellFormViewController.h"
#import "TermsViewController.h"


@interface RegistrationFormViewController : CustomCellFormViewController <UIAlertViewDelegate, ABWebserviceDelegate>
{
	
@private
	CreateUserJSONReader *createUserJSONReader;
	CheckLoginJSONReader *checkLoginJSONReader;
	CheckGlobusCardJSONReader *checkGlobusCardJSONReader;
}

@property (nonatomic, strong) IBOutlet TermsViewController *termsViewController;

@end

