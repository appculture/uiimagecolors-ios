//
//  TextFormfieldCell.m
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "TextFormfieldCell.h"
#import "StylesheetController.h"


@interface TextFormfieldCell ()

- (void)setActive:(BOOL)active;

@end


#define kTextFormfieldCellTextLabelWidth 280

NSString *const kTextFormfieldCellID = @"TextFormfieldCellID";


@implementation TextFormfieldCell

#pragma mark - Housekeeping

- (id)init
{
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTextFormfieldCellID]))
	{
		textView = [[UITextView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:textView];
		
		textView.delegate = self;
		
		textView.font = [UIFont fontWithName:@"GillSansAltOne" size:[UIFont smallSystemFontSize]];
		textView.backgroundColor = [UIColor clearColor];
		textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	}
	
	return self;
}


#pragma mark - Public methods / API

+ (CGFloat)heightForFormfieldDictionary:(NSDictionary *)theFormfieldDictionary valueDictionary:(NSDictionary *)theValueDictionary
{
	NSString *value = @"";
	NSString *name = [theFormfieldDictionary valueForKey:@"Name"];
	if (name)
		value = [theValueDictionary valueForKey:name];
	
	CGSize textViewSize;
	NSString *editableString = [theFormfieldDictionary valueForKey:@"Editable"];
	BOOL editable = (!editableString) ? YES : [editableString boolValue];
	if (!editable)
		textViewSize = [value boundingRectWithSize:CGSizeMake(kTextFormfieldCellTextLabelWidth, 500.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GillSansAltOne" size:[UIFont smallSystemFontSize]]} context:nil].size;
	else 
		textViewSize = CGSizeMake(kTextFormfieldCellTextLabelWidth, 100.0);
	
	return MAX(textViewSize.height + 13.0, 44.0);
}

- (void)setFormfieldDictionary:(NSDictionary *)theDictionary
{
	[super setFormfieldDictionary:theDictionary];
	
	[self updateValueLabel];
	textView.userInteractionEnabled = NO;
	
	if (self.action)
	{
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		
		if ([self.action isEqualToString:@"Go"])
			textView.returnKeyType = UIReturnKeyGo;
		else if ([self.action isEqualToString:@"Next"])
			textView.returnKeyType = UIReturnKeyNext;
		else
			textView.returnKeyType = UIReturnKeyDefault;
	}
	else
		self.selectionStyle = UITableViewCellSelectionStyleNone;	
	
	NSString *editableString = [theDictionary valueForKey:@"Editable"];
	BOOL editable = (!editableString) ? YES : [editableString boolValue];
	if (editable)
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		textView.editable = YES;
		textView.userInteractionEnabled = YES;
	}
	else
		textView.editable = NO;
	
	self.accessoryView = nil;

	NSString *accessory = [theDictionary valueForKey:@"Accessory"];
	if ([accessory isEqualToString:@"DisclosureIndicator"])
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	else
		self.accessoryType = UITableViewCellAccessoryNone;
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (BOOL)isFirstResponder
{
	return [textView isFirstResponder];
}

- (BOOL)becomeFirstResponder
{
	return [textView becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
	return [textView resignFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:(BOOL)animated];
	
	[self setActive:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:(BOOL)animated];
	
	[self setActive:highlighted];
}

- (void)updateValueLabel
{
	textView.text = self.value;
}


#pragma mark - Layouting

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect contentRect = self.contentView.bounds;
	
	textView.frame = CGRectMake(contentRect.origin.x + 5.0, contentRect.origin.y - 2.0, kTextFormfieldCellTextLabelWidth, contentRect.size.height);
}


#pragma mark - TextView delegates

- (void)textViewDidChange:(UITextView *)theTextView
{
	self.value = theTextView.text;
}

- (void)textViewDidEndEditing:(UITextView *)theTextView
{
	[self endEditing];
	[self hitReturn];
}

- (void)textViewDidBeginEditing:(UITextView *)theTextView
{
	[self beginEditing];
}


#pragma mark - Helper functions

- (void)setActive:(BOOL)active
{
	textView.textColor = [[StylesheetController sharedInstance] colorWithKey:(active && self.selectionStyle != UITableViewCellSelectionStyleNone) ? @"FormTableCellBackground" : @"FormTableCellTextValue"];
}

@end
