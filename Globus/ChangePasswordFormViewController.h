//
//  ChangePasswordFormViewController.h
//  Globus
//
//  Created by Patrik Oprandi on 26.03.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCellFormViewController.h"
#import "ChangePasswordJSONReader.h"
#import "WebserviceWithAuth.h"

@interface ChangePasswordFormViewController : CustomCellFormViewController <FormViewControllerDelegate, ABWebserviceDelegate, WebserviceAuthDataSource>
{
	
@private
	ChangePasswordJSONReader *changePasswordJSONReader;
}

@end
