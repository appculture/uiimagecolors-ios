//
//  ButtonCell.h
//  Globus
//
//  Created by Patrik Oprandi on 28.03.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kButtonCellID;

typedef enum
{
	ButtonCellAccessoryNone,
	ButtonCellAccessoryDisclosureIndicator,
	ButtonCellAccessoryDetailDisclosureButton,
	ButtonCellAccessoryCheckmark,
	ButtonCellAccessoryLoadingIndicator
} ButtonCellAccessoryType;

@interface ButtonCell : UITableViewCell
{
	UITableViewCellStyle tableViewCellStyle;
	ButtonCellAccessoryType buttonCellAccessoryType;
    BOOL isWineCategory;
}

@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) ButtonCellAccessoryType accessory;
@property (nonatomic) BOOL isWineCategory;

- (id)initWithStyle:(UITableViewCellStyle)style;

@end