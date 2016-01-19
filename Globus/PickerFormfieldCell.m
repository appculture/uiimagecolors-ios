//
//  PickerFormfieldCell.m
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "PickerFormfieldCell.h"
#import "StylesheetController.h"
#import "GlobusController.h"


@interface PickerFormfieldCell ()

+ (void)pickerViewAddToKeyWindow;
+ (void)keyboardWillShow:(NSNotification *)theNotification;

- (void)datePickerDidChange:(UIDatePicker *)datePicker;

- (void)setPickerValue:(NSString *)theValue;

@end


static UIView *gPickerView = nil;
static UIPickerView *gCustomPickerView = nil;
static UIDatePicker *gDatePickerView = nil;
static UIView *gSeparatorLineView = nil;
static NSDictionary *gFormfieldDictionary = nil;
static BOOL gPickerHidden = YES;

UIPopoverController *gPickerPopoverController = nil;
static UIView *gPickerParentView;
static CGRect gPickerPositionRect;

NSString *const kPickerFormfieldCellID = @"PickerFormfieldCellID";
NSString *const kDatePickerFormfieldCellID = @"DatePickerFormfieldCellID";

NSString *const PickerFormfieldCellPickerWillShowNotification = @"PickerFormfieldCellPickerWillShowNotification";
NSString *const PickerFormfieldCellPickerDidShowNotification = @"PickerFormfieldCellPickerDidShowNotification";
NSString *const PickerFormfieldCellPickerWillHideNotification = @"PickerFormfieldCellPickerWillHideNotification";
NSString *const PickerFormfieldCellPickerBoundsUserInfoKey = @"PickerFormfieldCellPickerBoundsUserInfoKey";
NSString *const PickerFormfieldCellPickerAnimationDurationUserInfoKey = @"PickerFormfieldCellPickerAnimationDurationUserInfoKey";


@implementation PickerFormfieldCell

@synthesize pickerValueLabel;

+ (void)initialize
{
	gPickerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 216.0)];
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
		gPickerView.backgroundColor = [[StylesheetController sharedInstance] colorWithKey:@"FormPickerViewBackground"];
	
	gCustomPickerView = [[UIPickerView alloc] initWithFrame:gPickerView.frame];
	[gPickerView addSubview:gCustomPickerView];
	gCustomPickerView.showsSelectionIndicator = YES;

	gDatePickerView = [[UIDatePicker alloc] initWithFrame:gPickerView.frame];
	[gPickerView addSubview:gDatePickerView];
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
	{
		gSeparatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 0.5)];
		gSeparatorLineView.backgroundColor = [[StylesheetController sharedInstance] colorWithKey:@"FormPickerViewSeparatorLine"];
		[gPickerView addSubview:gSeparatorLineView];
	}
	
	gPickerView.frame = gCustomPickerView.frame;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		UIViewController *viewController = [[UIViewController alloc] init];
		viewController.view = gPickerView;
		gPickerPopoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
		gPickerPopoverController.popoverContentSize = gPickerView.frame.size;
	}
	
	gPickerHidden = YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

+ (void)pickerViewAddToKeyWindow
{
	if (gPickerView.superview)
		return;
	
	UIView *parentView = [[UIApplication sharedApplication] keyWindow];
	gPickerView.frame = CGRectMake(parentView.bounds.origin.x, parentView.bounds.origin.y + parentView.bounds.size.height, parentView.bounds.size.width, gPickerView.bounds.size.height);
	[parentView addSubview:gPickerView];
}

- (id)init
{
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPickerFormfieldCellID])
	{
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		
		self.textLabel.numberOfLines = 2;
		
		pickerValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:pickerValueLabel];
		
		pickerValueLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"FormTableCellTextValue"];
		pickerValueLabel.backgroundColor = [UIColor clearColor];
		pickerValueLabel.highlightedTextColor = [UIColor blackColor];
		pickerValueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	}
	
	return self;
}

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
		pickerValueLabel.font = [UIFont fontWithName:@"GillSansAltOneLight" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFormfieldCellFontSize : kiPhoneFormfieldCellFontSize];
		
        CGFloat width = [[GlobusController sharedInstance] is_iPad] ? kiPadFormfieldCellTextLabelWidth : kiPhoneFormfieldCellTextLabelWidth;
        
        self.textLabel.frame = CGRectMake(contentRect.origin.x + 15.0, contentRect.origin.y + 5.0, width, contentRect.size.height - 10.0);
		pickerValueLabel.frame = CGRectMake(contentRect.origin.x + 15.0 + width + 10.0, contentRect.origin.y, contentRect.size.width - 10.0 - width - 10.0 - 15.0, contentRect.size.height);

	}
	else
	{
		pickerValueLabel.font = [UIFont fontWithName:@"GillSansAltOneLight" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFormfieldCellFontSize : kiPhoneFormfieldCellFontSize];
		CGRect pickerValueLabelFrame = CGRectInset(contentRect, 10.0, 0.0);
		if (self.imageView.image)
		{
			pickerValueLabelFrame.origin.x += self.imageView.image.size.width + 5.0;
			pickerValueLabelFrame.size.width -= self.imageView.image.size.width + 5.0;
		}
		pickerValueLabel.frame = pickerValueLabelFrame;
	}
}


#pragma mark - Public methods / API

- (void)setFormfieldDictionary:(NSDictionary *)theDictionary
{
	[super setFormfieldDictionary:theDictionary];
	
	if (self.required)
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
	
	labelEnabled = (self.textLabel.text && self.textLabel.text.length > 0);
	
	self.accessoryView = nil;
}

- (void)updateValueLabel
{
	pickerValueLabel.text = @"";
	
	NSString *pickerType = [formfieldDictionary valueForKey:@"PickerType"];
	if (pickerType)
	{
		gDatePickerView.maximumDate = [NSDate date];
		
		if ([pickerType isEqualToString:@"Date"])
			gDatePickerView.datePickerMode = UIDatePickerModeDate;
		else if ([pickerType isEqualToString:@"DateAndTime"])
			gDatePickerView.datePickerMode = UIDatePickerModeDateAndTime;
		else if ([pickerType isEqualToString:@"Time"])
			gDatePickerView.datePickerMode = UIDatePickerModeTime;
		
        if(self.value) {
			pickerValueLabel.text = self.value;
        }
		
	}
	else
	{
		for (NSDictionary *optionDictionary in [formfieldDictionary valueForKey:@"Options"])
			if ([self.value isEqualToString:[optionDictionary valueForKey:@"Value"]])
			{
				NSString *label = [optionDictionary valueForKey:@"Label"];
				if (!label)
					label = NSLocalizedString([optionDictionary objectForKey:@"LabelKey"], @"");
				
				pickerValueLabel.text = label;
				NSString *imageName = [optionDictionary valueForKey:@"ImageName"];
				self.imageView.image = (imageName.length > 0) ? [UIImage imageNamed:imageName] : nil;
			}
	}
}

- (void)updatePickerType
{
	NSString *pickerType = [formfieldDictionary valueForKey:@"PickerType"];
	if (pickerType)
	{
		gCustomPickerView.hidden = YES;
		gDatePickerView.hidden = NO;
	}
	else
	{
		gCustomPickerView.hidden = NO;
		gDatePickerView.hidden = YES;
	}
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	[self beginEditing];
	
	return YES;
}

- (void)beginEditing
{
	gCustomPickerView.delegate = self;
	gCustomPickerView.dataSource = self;
	[gDatePickerView addTarget:self action:@selector(datePickerDidChange:) forControlEvents:UIControlEventValueChanged];
	gPickerPositionRect = self.frame;
	gPickerParentView = self.superview;
	
	gFormfieldDictionary = formfieldDictionary;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		gPickerPopoverController.delegate = self;
	}
	
	NSString *pickerType = [formfieldDictionary valueForKey:@"PickerType"];
	if (pickerType)
	{
		NSString *value = [delegate formfieldValueForName:[gFormfieldDictionary valueForKey:@"Name"]];
		if (value)
		{
			NSDate *date = [[GlobusController sharedInstance] dateFromGermanDateString:value];
			[gDatePickerView setDate:date animated:YES];
		}
	} else
	{
		NSString *value = [delegate formfieldValueForName:[gFormfieldDictionary valueForKey:@"Name"]];
		NSArray *options = [gFormfieldDictionary valueForKey:@"Options"];
		
		if (!value)
			[gCustomPickerView selectRow:0 inComponent:0 animated:NO];
		else 
		{
			for (NSInteger row = 0; row < options.count; row++)
			{				
				if ([value isEqualToString:[[options objectAtIndex:row] valueForKey:@"Value"]])
					[gCustomPickerView selectRow:row inComponent:0 animated:NO];
			}
			
		}
		
	}
	
	[PickerFormfieldCell pickerShow:YES animated:YES];
	
	[super beginEditing];
}

- (void)endEditing
{
	gCustomPickerView.delegate = nil;
	gCustomPickerView.dataSource = nil;
	[gDatePickerView removeTarget:self action:@selector(datePickerDidChange:) forControlEvents:UIControlEventValueChanged];
	
	gFormfieldDictionary = nil;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		gPickerPopoverController.delegate = nil;
	}
	
	[PickerFormfieldCell pickerShow:NO animated:YES];
	
	[super endEditing];
}

+ (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	NSDictionary *userInfoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGRect:gPickerView.bounds], PickerFormfieldCellPickerBoundsUserInfoKey, [NSNumber numberWithDouble:0.0], PickerFormfieldCellPickerAnimationDurationUserInfoKey, nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:PickerFormfieldCellPickerDidShowNotification object:nil userInfo:userInfoDictionary];
}

+ (void)pickerShow:(BOOL)show animated:(BOOL)animated
{
	if ((show && !gPickerHidden) || (!show && gPickerHidden))
		return;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		if (show)
			[gPickerPopoverController presentPopoverFromRect:gPickerPositionRect inView:gPickerParentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:animated];
		else
			[gPickerPopoverController dismissPopoverAnimated:animated];
		
		gPickerHidden = !gPickerHidden;
	}
	else
	{
		[PickerFormfieldCell pickerViewAddToKeyWindow];
		
		NSDictionary *userInfoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGRect:gPickerView.bounds], PickerFormfieldCellPickerBoundsUserInfoKey, [NSNumber numberWithDouble:animated ? 0.3 : 0.0], PickerFormfieldCellPickerAnimationDurationUserInfoKey, nil];
		if (show)
			[[NSNotificationCenter defaultCenter] postNotificationName:PickerFormfieldCellPickerWillShowNotification object:nil userInfo:userInfoDictionary];
		else
			[[NSNotificationCenter defaultCenter] postNotificationName:PickerFormfieldCellPickerWillHideNotification object:nil userInfo:userInfoDictionary];
		
		gPickerHidden = !gPickerHidden;
		if (animated)
		{
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.3];
			if (show)
			{
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
			}
		}
		
		gPickerView.frame = CGRectOffset(gPickerView.frame, 0.0, show ? -gPickerView.frame.size.height : gPickerView.frame.size.height);
		
		if (animated)
			[UIView commitAnimations];
		else
			[[NSNotificationCenter defaultCenter] postNotificationName:PickerFormfieldCellPickerDidShowNotification object:nil userInfo:userInfoDictionary];
	}
}


#pragma mark - PopoverController delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[self endEditing];
}


#pragma mark - Picker data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	NSArray *options = [gFormfieldDictionary valueForKey:@"Options"];
	
	return options.count;
}

/*
 - (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
 {
 NSArray *options = [gFormfieldDictionary valueForKey:@"Options"];
 
 return ABLocalizedString([[options objectAtIndex:row] objectForKey:@"LabelKey"], @"");
 }
 */

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	NSDictionary *optionDictionary = [[gFormfieldDictionary valueForKey:@"Options"] objectAtIndex:row];
	
	PickerRowView *rowView = (PickerRowView *)view;
	if (!rowView)
		rowView = [[PickerRowView alloc] initWithFrame:CGRectMake(0.0, 0.0, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
	
	NSString *label = [optionDictionary valueForKey:@"Label"];
	if (!label)
		label = NSLocalizedString([optionDictionary objectForKey:@"LabelKey"], @"");
	
	rowView.titleLabel.text = label;
	NSString *imageName = [optionDictionary objectForKey:@"ImageName"];
	rowView.imageView.image = (imageName.length > 0) ? [UIImage imageNamed:imageName] : nil;
	
	return rowView;
}

#pragma mark - GUI actions

- (void)datePickerDidChange:(UIDatePicker *)datePicker
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSString *dateFormat = [gFormfieldDictionary valueForKey:@"DateFormat"];
	if (!dateFormat)
		dateFormat = @"dd.MM.yyyy";
	[dateFormatter setDateFormat:dateFormat];
	[self setPickerValue:[dateFormatter stringFromDate:datePicker.date]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	NSArray *options = [gFormfieldDictionary valueForKey:@"Options"];
	NSDictionary *optionDictionary = [options objectAtIndex:row];
	
	[self setPickerValue:[optionDictionary valueForKey:@"Value"]];
}


#pragma mark - Helper functions

+ (void)keyboardWillShow:(NSNotification *)theNotification 
{
	[PickerFormfieldCell pickerShow:NO animated:YES];
}

- (void)setPickerValue:(NSString *)theValue
{
	NSString *formfieldName = [gFormfieldDictionary valueForKey:@"Name"];
	
	[delegate setFormfieldValue:theValue forName:formfieldName updateCell:NO];
	[[NSNotificationCenter defaultCenter] postNotificationName:FormfieldDidChangeNotification object:gFormfieldDictionary];
	
	// update label if formfieldcell is visible cell
	PickerFormfieldCell *formfieldCell = (PickerFormfieldCell *)[delegate formfieldCellForName:formfieldName];
	if (formfieldCell)
	{
		NSString *pickerType = [gFormfieldDictionary valueForKey:@"PickerType"];
		if (pickerType)
			formfieldCell.pickerValueLabel.text = theValue;
		else
		{
			for (NSDictionary *optionDictionary in [gFormfieldDictionary valueForKey:@"Options"])
				if ([theValue isEqualToString:[optionDictionary valueForKey:@"Value"]])
				{
					NSString *label = [optionDictionary valueForKey:@"Label"];
					if (!label)
						label = NSLocalizedString([optionDictionary objectForKey:@"LabelKey"], @"");
					
					formfieldCell.pickerValueLabel.text = label;
					NSString *imageName = [optionDictionary valueForKey:@"ImageName"];
					self.imageView.image = (imageName.length > 0) ? [UIImage imageNamed:imageName] : nil;
				}
		}
	}
	
	if ([gFormfieldDictionary valueForKey:@"Action"])
		[self hitReturn];
}

@end


@implementation PickerRowView

@synthesize titleLabel;
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		titleLabel.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.font = [UIFont systemFontOfSize:19.0];
		
		[self addSubview:titleLabel];
		
		imageView = [[UIImageView alloc] initWithFrame:CGRectInset(frame, 10.0, 0.0)];
		imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
		imageView.contentMode = UIViewContentModeLeft;
		
		[self addSubview:imageView];
	}
	
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect labelFrame = CGRectInset(self.frame, 10.0, 0.0);
	if (imageView.image)
	{
		labelFrame.origin.x += imageView.image.size.width + 5.0;
		labelFrame.size.width -= imageView.image.size.width + 5.0;
	}
	titleLabel.frame = labelFrame;
}

@end