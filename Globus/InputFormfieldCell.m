//
//  InputFormfieldCell.m
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "InputFormfieldCell.h"
#import "StylesheetController.h"
#import "GlobusController.h"


@interface InputFormfieldCell ()

- (void)textFieldTextDidChange:(UITextField *)textField;

@end


NSString *const kInputFormfieldCellID = @"InputFormfieldCellID";


@implementation InputFormfieldCell

#pragma mark - Housekeeping

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self configureLabels];
}

- (void)configureLabels {
    self.textLabel.numberOfLines = 2;
    self.textLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFormfieldCellFontSize : kiPhoneFormfieldCellFontSize];
}

- (id)init
{
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInputFormfieldCellID]))
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		textField = [[UITextField alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:textField];

		textField.delegate = self;
		[textField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
		textField.textColor = [[StylesheetController sharedInstance] colorWithKey:@"FormTableCellTextValue"];
		textField.borderStyle = UITextBorderStyleNone;
		textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self configureLabels];
	}
	
	return self;
}


#pragma mark - Public methods / API

- (void)setFormfieldDictionary:(NSDictionary *)theDictionary
{
	[super setFormfieldDictionary:theDictionary];

	NSString *name = [theDictionary valueForKey:@"Name"];
	
	if (self.required || [name isEqualToString:@"StrassenNr"])
	{
		self.textLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"FormTableCellText"];
		self.textLabel.highlightedTextColor = [[StylesheetController sharedInstance] colorWithKey:@"FormTableCellText"];
	}else
	{	
		self.textLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"FormTableCellTextOptional"];
		self.textLabel.highlightedTextColor = [[StylesheetController sharedInstance] colorWithKey:@"FormTableCellTextOptional"];
	}
	self.textLabel.text = self.label;
	[self updateValueLabel];

	textField.placeholder = NSLocalizedString([theDictionary valueForKey:@"PlaceholderLabelKey"], @"");
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	textField.secureTextEntry = NO;

	NSString *keyboardType = [theDictionary valueForKey:@"KeyboardType"];
	if ([keyboardType isEqualToString:@"EmailAddress"])
		textField.keyboardType = UIKeyboardTypeEmailAddress;
	else if ([keyboardType isEqualToString:@"Numbers"])
		textField.keyboardType = UIKeyboardTypeNumberPad;
	else if ([keyboardType isEqualToString:@"NumbersAndPunctuation"])
		textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	else if ([keyboardType isEqualToString:@"Phone"])
		textField.keyboardType = UIKeyboardTypePhonePad;
	else if ([self.type isEqualToString:@"Password"])
	{
		textField.keyboardType = UIKeyboardTypeDefault;
		textField.secureTextEntry = YES;
	}
	else
	{
		textField.keyboardType = UIKeyboardTypeDefault;
		textField.autocorrectionType = UITextAutocorrectionTypeYes;
		textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	}

	if ([self.action isEqualToString:@"Go"])
		textField.returnKeyType = UIReturnKeyGo;
	else if ([self.action isEqualToString:@"Next"])
		textField.returnKeyType = UIReturnKeyNext;
	else
		textField.returnKeyType = UIReturnKeyDefault;

	NSString *editableString = [theDictionary valueForKey:@"Editable"];
	BOOL editable = (!editableString) ? YES : [editableString boolValue];
	if (editable)
	{
		textField.userInteractionEnabled = YES;
		textField.clearButtonMode = UITextFieldViewModeAlways;
	}
	else
	{
		textField.userInteractionEnabled = NO;
		textField.clearButtonMode = UITextFieldViewModeNever;
        UIColor *disabledTextColor = [[StylesheetController sharedInstance] colorWithKey:@"FormTableCellTextValueReadOnly"];
        if(disabledTextColor){
            textField.textColor = disabledTextColor;
        }
        
	}

	self.accessoryView = nil;
	
	NSString *accessory = [theDictionary valueForKey:@"Accessory"];
	if ([accessory isEqualToString:@"DisclosureIndicator"])
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	else
		self.accessoryType = UITableViewCellAccessoryNone;

	labelEnabled = (self.textLabel.text && self.textLabel.text.length > 0);
	
	int dictMaxLength = [[theDictionary valueForKey:@"MaxLength"] intValue];
	if (dictMaxLength > 0)
	{
		maxLength = dictMaxLength;
	} else {
		maxLength = 0;
	}
}

- (void)updateValueLabel
{
	textField.text = self.value;
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (BOOL)isFirstResponder
{
	return [textField isFirstResponder];
}

- (BOOL)becomeFirstResponder
{
	return [textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
	return [textField resignFirstResponder];
}


#pragma mark - Layouting

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect contentRect = self.contentView.bounds;
	
	if (labelEnabled)
	{
		if ([self.textLabel.text rangeOfString:@"\n"].location != NSNotFound)
			self.textLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[UIFont smallSystemFontSize]];
		else
			self.textLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFormfieldCellFontSize : kiPhoneFormfieldCellFontSize];
		textField.font = [UIFont fontWithName:@"GillSansAltOneLight" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFormfieldCellFontSize : kiPhoneFormfieldCellFontSize];
			
		NSString *keyboardType = [formfieldDictionary valueForKey:@"KeyboardType"];
		NSString *type = [formfieldDictionary valueForKey:@"Type"];
		CGFloat formfieldCellWidth;
		
		if ([keyboardType isEqualToString:@"EmailAddress"] || [type isEqualToString:@"Password"])
		{
			self.textLabel.frame = CGRectMake(contentRect.origin.x + 15.0, contentRect.origin.y + 5.0, [[GlobusController sharedInstance] is_iPad] ? kiPadFormfieldCellTextLabelWidthEmail : kiPhoneFormfieldCellTextLabelWidthEmail, contentRect.size.height - 10.0);
			formfieldCellWidth = [[GlobusController sharedInstance] is_iPad] ? kiPadFormfieldCellTextLabelWidthEmail : kiPhoneFormfieldCellTextLabelWidthEmail;
		} else
		{
			self.textLabel.frame = CGRectMake(contentRect.origin.x + 15.0, contentRect.origin.y + 5.0, [[GlobusController sharedInstance] is_iPad] ? kiPadFormfieldCellTextLabelWidth : kiPhoneFormfieldCellTextLabelWidth, contentRect.size.height - 10.0);
			formfieldCellWidth = [[GlobusController sharedInstance] is_iPad] ? kiPadFormfieldCellTextLabelWidth : kiPhoneFormfieldCellTextLabelWidth;
		}
			
			
         
        
		textField.frame = CGRectMake(contentRect.origin.x + 15.0 + formfieldCellWidth + 10.0, contentRect.origin.y, contentRect.size.width - 10.0 - formfieldCellWidth - 10.0 - 10.0, contentRect.size.height);
	}
	else
	{
		textField.font = [UIFont fontWithName:@"GillSansAltOneLight" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFormfieldCellFontSize : kiPhoneFormfieldCellFontSize];
		textField.frame = CGRectMake(contentRect.origin.x + 15.0, contentRect.origin.y, contentRect.size.width - 10.0 - 10.0, contentRect.size.height);
	}
}


#pragma mark - TextField delegates

- (void)textFieldTextDidChange:(UITextField *)theTextField
{
	self.value = theTextField.text;
}

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if (textField.keyboardType == UIKeyboardTypeNumberPad)
	{
		NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
		NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:string];
		
		if (![alphaNums isSupersetOfSet:inStringSet])
			return NO;
	}
	
	NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
    if([newString length] > maxLength && maxLength != 0)
		return NO;

	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField
{
	[self endEditing];
}

- (void)textFieldDidBeginEditing:(UITextField *)theTextField
{
	[self beginEditing];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self hitReturn];
	
	return YES;
}

@end
