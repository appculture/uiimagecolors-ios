//
//  PickerFormfieldCell.h
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import <UIKit/UIKit.h>
#import "FormfieldCell.h"


extern NSString *const PickerFormfieldCellPickerWillShowNotification;
extern NSString *const PickerFormfieldCellPickerDidShowNotification;
extern NSString *const PickerFormfieldCellPickerWillHideNotification;
extern NSString *const PickerFormfieldCellPickerBoundsUserInfoKey;
extern NSString *const PickerFormfieldCellPickerAnimationDurationUserInfoKey;

extern NSString *const kPickerFormfieldCellID;
extern NSString *const kDatePickerFormfieldCellID;

@interface PickerFormfieldCell : FormfieldCell <UIPickerViewDelegate, UIPickerViewDataSource, UIPopoverControllerDelegate>
{
	UILabel	*pickerValueLabel;

@private
	BOOL labelEnabled;
}

@property (nonatomic, readonly) UILabel	*pickerValueLabel;

+ (void)pickerShow:(BOOL)show animated:(BOOL)animated;

- (void)updatePickerType;

@end


@interface PickerRowView : UIView
{
@private
	UIImageView *imageView;
	UILabel *titleLabel;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end