//
//  CustomCellFormViewController.h
//  Globus
//
//  Created by Mladen Djordjevic on 3/6/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormViewController.h"

@interface CustomCellFormViewController : FormViewController <UITableViewDataSource>
{
@private
	FormfieldCell *selectedCell;
}

- (BOOL)isModal;

@end
