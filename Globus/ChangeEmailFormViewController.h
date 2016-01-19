//
//  ChangeEmailFormViewController.h
//  Globus
//
//  Created by Mladen Djordjevic on 3/14/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCellFormViewController.h"
#import "ChangeEmailJSONReader.h"
#import "WebserviceWithAuth.h"
#import "CheckLoginJSONReader.h"

@interface ChangeEmailFormViewController : CustomCellFormViewController <FormViewControllerDelegate, ABWebserviceDelegate, WebserviceAuthDataSource>
{
	
@private
	ChangeEmailJSONReader *changeEmailJSONReader;
	CheckLoginJSONReader *checkLoginJSONReader;
}

@end
