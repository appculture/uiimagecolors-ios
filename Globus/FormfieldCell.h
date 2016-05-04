//
//  FormfieldCell.h
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//


#import <UIKit/UIKit.h>


#define kiPhoneFormfieldCellTextLabelWidth 115.0
#define kiPadFormfieldCellTextLabelWidth 300.0
#define kiPhoneFormfieldCellTextLabelWidthEmail 90.0
#define kiPadFormfieldCellTextLabelWidthEmail 260.0
#define kiPhoneFormfieldCellFontSize 16.0
#define kiPadFormfieldCellFontSize 22.0


extern NSString *const FormfieldDidChangeNotification;

@protocol FormfieldCellDelegate;


@interface FormfieldCell : UITableViewCell
{
	id <FormfieldCellDelegate> __unsafe_unretained delegate;

	NSDictionary *formfieldDictionary;
}

@property (nonatomic, unsafe_unretained) id <FormfieldCellDelegate> __unsafe_unretained delegate;

@property (nonatomic, strong) NSDictionary *formfieldDictionary;

- (NSString *)name;
- (NSString *)type;
- (NSString *)action;
- (NSString *)label;
- (NSString *)value;
- (void)setValue:(NSString *)theValue;
- (BOOL)required;

- (void)updateValueLabel;

- (void)beginEditing;
- (void)endEditing;
- (void)hitReturn;

@end


@protocol FormfieldCellDelegate <NSObject>

- (NSString *)valueForFormfieldCell:(FormfieldCell *)formfieldCell;
- (void)formfieldCell:(FormfieldCell *)formfieldCell setValue:(NSString *)theValue;

- (FormfieldCell *)formfieldCellForName:(NSString *)theName;
- (NSString *)formfieldValueForName:(NSString *)theName;
- (void)setFormfieldValue:(NSString *)theValue forName:(NSString *)theName updateCell:(BOOL)update;

@optional
- (void)formfieldCellDidBeginEditing:(FormfieldCell *)formfieldCell;
- (void)formfieldCellDidEndEditing:(FormfieldCell *)formfieldCell;
- (void)formfieldCellDidHitReturn:(FormfieldCell *)formfieldCell;

@end
