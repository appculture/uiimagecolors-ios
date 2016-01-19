//
//  FormfieldCell.m
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "FormfieldCell.h"
#import "StylesheetController.h"
#import "FormViewController.h"


NSString *const FormfieldDidChangeNotification = @"FormfieldDidChangeNotification";


@implementation FormfieldCell

@synthesize formfieldDictionary, delegate;


#pragma mark - Housekeeping

- (UITableViewCell *)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
	{
	}
	
	return self;
}


#pragma mark - Public methods / API

- (void)setFormfieldDictionary:(NSDictionary *)theDictionary
{
	if (formfieldDictionary != theDictionary)
	{
		formfieldDictionary = theDictionary;
		
		[self setNeedsLayout];
		[self setNeedsDisplay];	
	}
}

- (NSString *)name
{
	return [formfieldDictionary valueForKey:@"Name"];
}

- (NSString *)type
{
	return [formfieldDictionary valueForKey:@"Type"];
}

- (NSString *)action
{
	return [formfieldDictionary valueForKey:@"Action"];
}

- (NSString *)label
{
	if ([formfieldDictionary valueForKey:@"Label"])
		return [formfieldDictionary valueForKey:@"Label"];
	else
		return NSLocalizedString([formfieldDictionary valueForKey:@"LabelKey"], @"");
}

- (void)setValue:(NSString *)theValue
{
	[delegate formfieldCell:self setValue:theValue];
	[[NSNotificationCenter defaultCenter] postNotificationName:FormfieldDidChangeNotification object:formfieldDictionary];
}

- (NSString *)value
{
	return [delegate valueForFormfieldCell:self];
}

- (BOOL)required
{
	return [[formfieldDictionary valueForKey:@"Required"] boolValue];
	
	return NO;
}

- (void)updateValueLabel
{
	// do nothing
}

- (void)beginEditing
{
	if ([delegate respondsToSelector:@selector(formfieldCellDidBeginEditing:)])
		[delegate formfieldCellDidBeginEditing:self];		
}

- (void)endEditing
{
	if ([delegate respondsToSelector:@selector(formfieldCellDidEndEditing:)])
		[delegate formfieldCellDidEndEditing:self];		
}

- (void)hitReturn
{
	if ([delegate respondsToSelector:@selector(formfieldCellDidHitReturn:)])
		[delegate formfieldCellDidHitReturn:self];		
}

@end
