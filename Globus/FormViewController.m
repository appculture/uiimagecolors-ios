//
//  FormViewController.m
//
//  Copyright 2010 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "FormViewController.h"
#import "StylesheetController.h"
#import "ButtonFormfieldCell.h"
#import "InputFormfieldCell.h"
#import "TextFormfieldCell.h"
#import "SwitchFormfieldCell.h"
#import "PickerFormfieldCell.h"


@interface FormViewController ()

- (void)setFormfieldValue:(NSString *)theValue forName:(NSString *)theName updateCell:(BOOL)update;

- (NSArray *)formfieldArrayForFormDictionary:(NSDictionary *)theFormDictionary;

- (void)keyboardDidShow:(NSNotification *)theNotification;
- (void)keyboardWillHide:(NSNotification *)theNotification;
- (void)pickerWillShow:(NSNotification *)theNotification;
- (void)pickerDidShow:(NSNotification *)theNotification;
- (void)pickerWillHide:(NSNotification *)theNotification;

@end


@implementation FormViewController

@synthesize delegate, cancelButton, formDictionary, valueDictionary, formfieldArray;


#pragma mark - Housekeeping

- (id)initWithCoder:(NSCoder *)theDecoder
{
	if ((self = [super initWithCoder:theDecoder]))
	{
		valueDictionary = [[NSMutableDictionary alloc] init];
	}
	return self;
}


#pragma mark - GUI startup & shutdown

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// table view customizing
	tableView.backgroundColor = [[StylesheetController sharedInstance] colorWithKey:@"FormTableViewBackground"];
	
	cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"All.CancelText", @"") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
	saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"All.SaveText", @"") style:UIBarButtonItemStyleDone target:self action:@selector(saveAction)];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	self.pageName = self.formName;

	self.navigationItem.title = NSLocalizedString([formDictionary valueForKey:@"TitleKey"], @"");;

	if ([[formDictionary valueForKey:@"SaveEnabled"] boolValue] && [[formDictionary valueForKey:@"CancelEnabled"] boolValue])
	{
		self.navigationItem.hidesBackButton = YES;
		self.navigationItem.leftBarButtonItem = cancelButton;
		self.navigationItem.rightBarButtonItem = saveButton;
	}
	else
	{		
		if (self.navigationItem.leftBarButtonItem == cancelButton)
		{
			self.navigationItem.hidesBackButton = NO;
			self.navigationItem.leftBarButtonItem = nil;
		}
		if ([[formDictionary valueForKey:@"CancelEnabled"] boolValue])
			self.navigationItem.leftBarButtonItem = cancelButton;
		else if (self.navigationItem.rightBarButtonItem == saveButton)
			self.navigationItem.rightBarButtonItem = nil;
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickerWillShow:) name:PickerFormfieldCellPickerWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickerDidShow:) name:PickerFormfieldCellPickerDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickerWillHide:) name:PickerFormfieldCellPickerWillHideNotification object:nil];

	[self reloadForm];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
	
	[self endEditing];
}

- (void)viewDidDisappear:(BOOL)animated 
{
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PickerFormfieldCellPickerWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PickerFormfieldCellPickerDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PickerFormfieldCellPickerWillHideNotification object:nil];
}


#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [formfieldArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
	NSDictionary *sectionDictionary = [formfieldArray objectAtIndex:section];
	NSArray *rowArray = [sectionDictionary valueForKey:@"Rows"];
	
	return rowArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSDictionary *sectionDictionary = [formfieldArray objectAtIndex:section];
	
	return [self formViewController:self titleForHeaderForFormfieldGroup:sectionDictionary];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSDictionary *sectionDictionary = [formfieldArray objectAtIndex:section];
	
	return [self formViewController:self titleForFooterForFormfieldGroup:sectionDictionary];
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *sectionDictionary = [formfieldArray objectAtIndex:indexPath.section];
	NSArray *rowArray = [sectionDictionary valueForKey:@"Rows"];
	NSDictionary *rowDictionary = (NSDictionary *)[rowArray objectAtIndex:indexPath.row];

	NSString *type = [rowDictionary valueForKey:@"Type"];
	if ([type isEqualToString:@"Text"])
		return [TextFormfieldCell heightForFormfieldDictionary:rowDictionary valueDictionary:valueDictionary];
	
	return theTableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *sectionDictionary = [formfieldArray objectAtIndex:indexPath.section];
	NSArray *rowArray = [sectionDictionary valueForKey:@"Rows"];
	NSDictionary *rowDictionary = (NSDictionary *)[rowArray objectAtIndex:indexPath.row];
	
	return [self formViewController:self cellForFormfield:rowDictionary];
}

- (NSIndexPath *)tableView:(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath isEqual:tableView.indexPathForSelectedRow])
	{
		FormfieldCell *cell = (FormfieldCell *)[theTableView cellForRowAtIndexPath:tableView.indexPathForSelectedRow];
		[cell endEditing];
		return nil;
	}
	else
		return indexPath;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *sectionDictionary = [formfieldArray objectAtIndex:indexPath.section];
	NSArray *rowArray = [sectionDictionary valueForKey:@"Rows"];
	NSDictionary *rowDictionary = (NSDictionary *)[rowArray objectAtIndex:indexPath.row];

	FormfieldCell *cell = (FormfieldCell *)[theTableView cellForRowAtIndexPath:indexPath];
	[cell becomeFirstResponder];
		
	NSString *action = [rowDictionary valueForKey:@"Action"];
	if ([action isEqualToString:@"ShowForm"])
	{
		[self pushFormWithName:[rowDictionary valueForKey:@"FormName"] animated:YES];
	}
	else if ([action isEqualToString:@"ShowWebview"])
	{
		webViewController.URLString = [rowDictionary valueForKey:@"URLString"];
		[self.navigationController pushViewController:webViewController animated:YES];	
	}
	else if ([action isEqualToString:@"Save"])
	{
		[self saveAction];
		[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else
	{
		if ([[rowDictionary valueForKey:@"Type"] isEqualToString:@"Picker"])
		{
			[(PickerFormfieldCell *)[theTableView cellForRowAtIndexPath:indexPath] updatePickerType];
		}
		[self formViewController:self didSelectRow:rowDictionary];
	}
}


#pragma mark - Public methods / API

- (void)loadFormWithName:(NSString *)theFormName
{
	formDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:theFormName ofType:@"plist"]];	
}

- (void)pushFormWithName:(NSString *)theFormName animated:(BOOL)animated;
{
	formViewController.delegate = delegate;
	formViewController.valueDictionary = valueDictionary;
	[formViewController loadFormWithName:theFormName];
	[self.navigationController pushViewController:formViewController animated:animated];	
}

- (void)reloadForm
{
	self.formfieldArray = [self formfieldArrayForFormDictionary:formDictionary];
	[tableView reloadData];
}

- (void)reloadFormAnimated
{
	NSArray *oldFormFieldArray = formfieldArray;
	
	self.formfieldArray = [self formfieldArrayForFormDictionary:formDictionary];
	NSArray *newFormFieldArray = formfieldArray;
	
	NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
	NSMutableArray *insertArray = [[NSMutableArray alloc] init];
	
	// first store the old row-names in an Array for easier comparison later
	NSMutableDictionary *oldPathDictionary = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *oldSectionPathDictionary = [[NSMutableDictionary alloc] init];
	
	NSMutableIndexSet *deleteSectionIndexSet = [NSMutableIndexSet indexSet];
	NSMutableIndexSet *insertSectionIndexSet = [NSMutableIndexSet indexSet];
	
	for(NSDictionary *section in oldFormFieldArray)
	{
		NSUInteger sectionNr = [oldFormFieldArray indexOfObject:section];
		//[oldSectionIndexSet addIndex:sectionNr];
		[oldSectionPathDictionary setObject:[NSString stringWithFormat:@"%i", sectionNr] forKey:[NSString stringWithFormat:@"%i", sectionNr]];
		NSArray *rowArray = [section objectForKey:@"Rows"];
		
		for(NSDictionary *row in rowArray)
		{
			NSString *name = [row objectForKey:@"Name"];
			if(name)
			{
				NSUInteger rowNr = [rowArray indexOfObject:row];
				NSIndexPath *path = [NSIndexPath indexPathForRow:rowNr inSection:sectionNr];
				[oldPathDictionary setObject:path forKey:name];
			}
		} 
	} 
		
	// same for new row-names
	NSMutableDictionary *newPathDictionary = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *newSectionPathDictionary = [[NSMutableDictionary alloc] init];
	for(NSDictionary *section in newFormFieldArray)
	{
		NSUInteger sectionNr = [newFormFieldArray indexOfObject:section];
		//[newSectionIndexSet addIndex:sectionNr];
		[newSectionPathDictionary setObject:[NSString stringWithFormat:@"%i", sectionNr] forKey:[NSString stringWithFormat:@"%i", sectionNr]];
		NSArray *rowArray = [section objectForKey:@"Rows"];
		
		for(NSDictionary *row in rowArray)
		{
			NSString *name = [row objectForKey:@"Name"];
			if(name)
			{
				NSUInteger rowNr = [rowArray indexOfObject:row];
				NSIndexPath *path = [NSIndexPath indexPathForRow:rowNr inSection:sectionNr];
				[newPathDictionary setObject:path forKey:name];
			} 
		} 
	}
	
	NSArray *oldSectionNameArray = [oldSectionPathDictionary allKeys];
	NSArray *newSectionNameArray = [newSectionPathDictionary allKeys];
	
	for(NSString *oldSectionName in oldSectionNameArray) 
		if(![newSectionNameArray containsObject:oldSectionName]) 
			[deleteSectionIndexSet addIndex:[[oldSectionPathDictionary objectForKey:oldSectionName] intValue]];
	
	for(NSString *newSectionName in newSectionNameArray) 
		if(![oldSectionNameArray containsObject:newSectionName])
			[insertSectionIndexSet addIndex:[[newSectionPathDictionary objectForKey:newSectionName] intValue]];
	
	
	NSArray *oldNameArray = [oldPathDictionary allKeys];
	NSArray *newNameArray = [newPathDictionary allKeys];
	
	for(NSString *oldName in oldNameArray) 
		if(![newNameArray containsObject:oldName])
		{
			if (![deleteSectionIndexSet containsIndex:[[oldPathDictionary objectForKey:oldName] section]])
				[deleteArray addObject:[oldPathDictionary objectForKey:oldName]];
		}
			
	
	for(NSString *newName in newNameArray) 
		if(![oldNameArray containsObject:newName])
		{
			if (![insertSectionIndexSet containsIndex:[[newPathDictionary objectForKey:newName] section]])
				[insertArray addObject:[newPathDictionary objectForKey:newName]];
		}
			
	
	if (deleteArray.count > 0 || insertArray.count > 0 || deleteSectionIndexSet.count > 0 || insertSectionIndexSet.count > 0)
	{
		[tableView beginUpdates];

		if (deleteSectionIndexSet.count > 0)
			[tableView deleteSections:deleteSectionIndexSet withRowAnimation:UITableViewRowAnimationFade];
		if (insertSectionIndexSet.count > 0)
			[tableView insertSections:insertSectionIndexSet withRowAnimation:UITableViewRowAnimationFade];
		if (deleteArray.count > 0)
			[tableView deleteRowsAtIndexPaths:deleteArray withRowAnimation:UITableViewRowAnimationFade];
		if (insertArray.count > 0)
			[tableView insertRowsAtIndexPaths:insertArray withRowAnimation:UITableViewRowAnimationFade];

		[tableView endUpdates];
	}
}

- (void)saveAction
{
	[self endEditing];
	
	if ([self formViewControllerShouldSave:self] && [delegate respondsToSelector:@selector(formViewControllerDidSave:)])
		[delegate formViewControllerDidSave:self];	
}

- (void)cancelAction
{
	[self endEditing];
	
	if ([self formViewControllerShouldCancel:self] && [delegate respondsToSelector:@selector(formViewControllerDidCancel:)])
		[delegate formViewControllerDidCancel:self];
}

- (NSString *)formName
{
	return [formDictionary valueForKey:@"Name"];
}

- (void)formfieldValuesClear
{
	for (NSDictionary *sectionDictionary in formfieldArray)
		for (NSDictionary *rowDictionary in [sectionDictionary objectForKey:@"Rows"])
		{
			NSString *name = [rowDictionary valueForKey:@"Name"];
			if (name)
				[self setFormfieldValue:nil forName:name];
		}
}

- (NSString *)formfieldValueForName:(NSString *)theName
{
	if (!theName)
		return nil;
	
	return [valueDictionary valueForKey:theName];
}

- (void)setFormfieldValue:(NSString *)theValue forName:(NSString *)theName
{
	[self setFormfieldValue:theValue forName:theName updateCell:YES];
}

- (void)focusForFormfieldName:(NSString *)theFormfieldName
{
	if (!theFormfieldName)
	{
		[self endEditing];
		return;
	}
	
	NSIndexPath *indexPath = [self indexPathForFormfieldWithName:theFormfieldName];
	if (indexPath)
	{
		FormfieldCell *cell = (FormfieldCell *)[tableView cellForRowAtIndexPath:indexPath];
		if (([[cell.formfieldDictionary valueForKey:@"Type"] isEqualToString:@"Picker"] || [[cell.formfieldDictionary valueForKey:@"Type"] isEqualToString:@"DatePicker"]))	{
			[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:NO];
		}
		if ([cell canBecomeFirstResponder])
			[cell becomeFirstResponder];
		else
			[self endEditing];
	}
}

- (NSString *)nameOfFollowingFormfieldWithName:(NSString *)theFormfieldName
{
	NSString *name = nil;
	
	for (NSInteger section = formfieldArray.count - 1; section >= 0; section--)
	{
		NSArray *rowArray = [[formfieldArray objectAtIndex:section] objectForKey:@"Rows"];
		for (NSInteger row = rowArray.count - 1; row >= 0; row--)
		{
			NSDictionary *rowDictionary = [rowArray objectAtIndex:row];
			if ([[rowDictionary valueForKey:@"Name"] isEqualToString:theFormfieldName])
				return name;
			name = [rowDictionary valueForKey:@"Name"];
		}
	}

	return name;
}

- (FormfieldCell *)formfieldCellForName:(NSString *)theName
{
	for (FormfieldCell *cell in tableView.visibleCells)
		if ([cell.name isEqualToString:theName])
			return cell;
	
	return nil;
}

- (NSIndexPath *)indexPathForFormfieldWithName:(NSString *)theFormfieldName
{
	NSUInteger section, row;
	
	for (section = 0; section < formfieldArray.count; section++)
	{
		NSArray *rowArray = [[formfieldArray objectAtIndex:section] objectForKey:@"Rows"];
		for (row = 0; row < rowArray.count; row++)
		{
			NSDictionary *rowDictionary = [rowArray objectAtIndex:row];
			if ([[rowDictionary valueForKey:@"Name"] isEqualToString:theFormfieldName])
				return [NSIndexPath indexPathForRow:row inSection:section];
		}
	}
	
	return nil;
}

- (BOOL)hasMissingRequiredFormfields
{
	for (NSDictionary *sectionDictionary in formfieldArray)
		for (NSDictionary *rowDictionary in [sectionDictionary objectForKey:@"Rows"])
		{
			NSString *name = [rowDictionary valueForKey:@"Name"];
			NSString *required = [rowDictionary valueForKey:@"Required"];
			
			if ((required && [required boolValue] && [[valueDictionary valueForKey:name] length] == 0) || 
				(required && [required boolValue] && [[valueDictionary valueForKey:name] isEqualToString:@" "]) ||
				(required && [required boolValue] && ![valueDictionary valueForKey:name]))
				return YES;
		}
	
	return NO;
}

- (NSArray *)formfieldArrayForFormDictionary:(NSDictionary *)theFormDictionary
{
	NSMutableArray *array = [NSMutableArray array];
	
	for (NSDictionary *sectionDictinary in [theFormDictionary valueForKey:@"Sections"])
	{
		NSMutableDictionary *filteredSectionDictionary = [NSMutableDictionary dictionaryWithDictionary:sectionDictinary];
		if ([self formViewController:self shouldDisplayFormfieldGroup:filteredSectionDictionary])
		{
			NSArray *rowArray = [sectionDictinary objectForKey:@"Rows"];
			
			NSMutableArray *filteredRowArray = [[NSMutableArray alloc] init];
			for (NSDictionary *formfieldDictionary in rowArray)
				if ([self formViewController:self shouldDisplayFormfield:formfieldDictionary])
					[filteredRowArray addObject:formfieldDictionary];
			
			[filteredSectionDictionary setObject:filteredRowArray forKey:@"Rows"];
			
			if (filteredRowArray.count > 0)
				[array addObject:filteredSectionDictionary];
		}
	}
	
	return array;
}

- (NSString *)formViewController:(FormViewController *)theFormViewController titleForHeaderForFormfieldGroup:(NSDictionary *)formfieldGroupDictionary
{
	NSString *key = [formfieldGroupDictionary valueForKey:@"HeaderLabelKey"];
	if (key)
		return NSLocalizedString(key, @"");
	
	return nil;
}

- (NSString *)formViewController:(FormViewController *)theFormViewController titleForFooterForFormfieldGroup:(NSDictionary *)formfieldGroupDictionary
{
	NSString *key = [formfieldGroupDictionary valueForKey:@"FooterLabelKey"];
	if (key)
		return NSLocalizedString(key, @"");
	
	return nil;
}

- (FormfieldCell *)formViewController:(FormViewController *)theFormViewController cellForFormfield:(NSDictionary *)formfieldDictionary
{
	FormfieldCell *cell = nil;

	NSString *type = [formfieldDictionary valueForKey:@"Type"];
	if ([type isEqualToString:@"Button"])
	{
		cell = (FormfieldCell *)[theFormViewController.tableView dequeueReusableCellWithIdentifier:kButtonFormfieldCellID];
		if (!cell)
			cell = [[ButtonFormfieldCell alloc] init];
	}
	else if ([type isEqualToString:@"Input"] || [type isEqualToString:@"Password"])
	{
		cell = (FormfieldCell *)[theFormViewController.tableView dequeueReusableCellWithIdentifier:kInputFormfieldCellID];
		if (!cell)
			cell = [[InputFormfieldCell alloc] init];
	}
	else if ([type isEqualToString:@"Switch"])
	{
		cell = (FormfieldCell *)[theFormViewController.tableView dequeueReusableCellWithIdentifier:kSwitchFormfieldCellID];
		if (!cell)
			cell = [[SwitchFormfieldCell alloc] init];
	}
	else if ([type isEqualToString:@"Picker"])
	{
		NSString *pickerType = [formfieldDictionary valueForKey:@"PickerType"];
		if ([pickerType isEqualToString:@"Date"])
			cell = (FormfieldCell *)[theFormViewController.tableView dequeueReusableCellWithIdentifier:kDatePickerFormfieldCellID];
		else
			cell = (FormfieldCell *)[theFormViewController.tableView dequeueReusableCellWithIdentifier:kPickerFormfieldCellID];
		
		if (!cell)
			cell = [[PickerFormfieldCell alloc] init];
	}
	else // if ([type isEqualToString:@"Text"])
	{
		cell = (FormfieldCell *)[theFormViewController.tableView dequeueReusableCellWithIdentifier:kTextFormfieldCellID];
		if (!cell)
			cell = [[TextFormfieldCell alloc] init];
	}
	
	cell.delegate = self;
	cell.formfieldDictionary = formfieldDictionary;
	
	return cell;	
}

- (BOOL)formViewController:(FormViewController *)formViewController shouldDisplayFormfieldGroup:(NSDictionary *)formfieldGroupDictionary
{
	return YES;
}

- (BOOL)formViewController:(FormViewController *)formViewController shouldDisplayFormfield:(NSDictionary *)formfieldDictionary
{
	return YES;
}

- (void)formViewController:(FormViewController *)formViewController didSelectRow:(NSDictionary *)formfieldDictionary
{
	// do nothing by default
}

- (BOOL)formViewControllerShouldCancel:(FormViewController *)formViewController
{
	return YES;
}

- (BOOL)formViewControllerShouldSave:(FormViewController *)formViewController
{
	return YES;
}


#pragma mark - FormfieldCell delegates

- (NSString *)valueForFormfieldCell:(FormfieldCell *)formfieldCell
{
	NSString *name = [formfieldCell.formfieldDictionary valueForKey:@"Name"];
	
	return [self formfieldValueForName:name];
}

- (void)formfieldCell:(FormfieldCell *)formfieldCell setValue:(NSString *)theValue
{
	NSString *name = [formfieldCell.formfieldDictionary valueForKey:@"Name"];
	
	[self setFormfieldValue:theValue forName:name updateCell:NO];
}

- (void)formfieldCellDidEndEditing:(FormfieldCell *)formfieldCell
{
	[tableView deselectRowAtIndexPath:[tableView indexPathForCell:formfieldCell] animated:YES];
}

- (void)formfieldCellDidBeginEditing:(FormfieldCell *)formfieldCell
{
	[tableView selectRowAtIndexPath:[tableView indexPathForCell:formfieldCell] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)formfieldCellDidHitReturn:(FormfieldCell *)formfieldCell
{
	NSString *action = [formfieldCell.formfieldDictionary valueForKey:@"Action"];
	NSString *name = [formfieldCell.formfieldDictionary valueForKey:@"Name"];

	if ([action isEqualToString:@"Go"])
		[self saveAction];
	else if ([action isEqualToString:@"Next"])
		[self focusForFormfieldName:[self nameOfFollowingFormfieldWithName:name]];
}


#pragma mark - Helper functions

- (void)endEditing
{
	[tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:YES];

	[self.view endEditing:YES];
	[PickerFormfieldCell pickerShow:NO animated:YES];
}

- (void)setFormfieldValue:(NSString *)theValue forName:(NSString *)theName updateCell:(BOOL)update
{
	if (!theName)
		return;
	
	if (theValue)
		[valueDictionary setValue:theValue forKey:theName];
	else
		[valueDictionary removeObjectForKey:theName];
	
	if (update)
	{
		FormfieldCell *cell = [self formfieldCellForName:theName];
		if (cell)
			[cell updateValueLabel];
	}
}


#pragma mark - Notifications

- (void)pickerWillShow:(NSNotification *)theNotification
{
	[self.view endEditing:YES];
}

- (void)pickerDidShow:(NSNotification *)theNotification
{
    [self moveViewForPickerWithUserInfo:theNotification.userInfo up:YES];
}

- (void)pickerWillHide:(NSNotification *)theNotification
{
    [self moveViewForPickerWithUserInfo:theNotification.userInfo up:NO];
}

- (void)moveViewForPickerWithUserInfo:(NSDictionary *)userInfo up:(BOOL)up
{
	CGRect pickerRect = [[userInfo objectForKey:PickerFormfieldCellPickerBoundsUserInfoKey] CGRectValue];
	NSTimeInterval animationDuration = [[userInfo objectForKey:PickerFormfieldCellPickerAnimationDurationUserInfoKey] doubleValue];
	
	pickerRect = [self.view convertRect:pickerRect toView:nil];
	
	CGFloat insetHeight = 0.0;
	
	if (up)
	{
		insetHeight = pickerRect.size.height;
		if (!self.tabBarController.tabBar.hidden && !self.tabBarController.tabBar.translucent)
			insetHeight -= self.tabBarController.tabBar.frame.size.height;
		if (!self.navigationController.toolbarHidden && !self.navigationController.toolbar.translucent)
			insetHeight -= self.navigationController.toolbar.frame.size.height;
	}
	else
	{
		if (!self.tabBarController.tabBar.hidden && self.tabBarController.tabBar.translucent)
			insetHeight += self.tabBarController.tabBar.frame.size.height;
		if (!self.navigationController.toolbarHidden && self.navigationController.toolbar.translucent)
			insetHeight += self.navigationController.toolbar.frame.size.height;
	}
	
	UIEdgeInsets contentInsets = tableView.contentInset;
	contentInsets.bottom = insetHeight;
	
	UIEdgeInsets scrollIndicatorInsets = tableView.scrollIndicatorInsets;
	scrollIndicatorInsets.bottom = insetHeight;
	
	void (^animations)(void) = ^(void)
	{
		tableView.contentInset = contentInsets;
		tableView.scrollIndicatorInsets = scrollIndicatorInsets;
	};
	
	void (^completion)(BOOL) = ^(BOOL finished)
	{
		[tableView scrollToRowAtIndexPath:tableView.indexPathForSelectedRow atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	};
	
	[UIView animateWithDuration:animationDuration delay:0.0 options:kNilOptions animations:animations completion:completion];
}

- (void)keyboardDidShow:(NSNotification*)theNotification
{
    [self moveViewForKeyboardWithUserInfo:theNotification.userInfo up:YES];
}

- (void)keyboardWillHide:(NSNotification*)theNotification
{
    [self moveViewForKeyboardWithUserInfo:theNotification.userInfo up:NO];
}

- (void)moveViewForKeyboardWithUserInfo:(NSDictionary *)userInfo up:(BOOL)up
{
	CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
	
	keyboardRect = [self.view convertRect:keyboardRect toView:nil];
	
	CGFloat insetHeight = 0.0;
	
	if (up)
	{
		insetHeight = keyboardRect.size.height;
		if (!self.tabBarController.tabBar.hidden && !self.tabBarController.tabBar.translucent)
			insetHeight -= self.tabBarController.tabBar.frame.size.height;
		if (!self.navigationController.toolbarHidden && !self.navigationController.toolbar.translucent)
			insetHeight -= self.navigationController.toolbar.frame.size.height;
	}
	else
	{
		if (!self.tabBarController.tabBar.hidden && self.tabBarController.tabBar.translucent)
			insetHeight += self.tabBarController.tabBar.frame.size.height;
		if (!self.navigationController.toolbarHidden && self.navigationController.toolbar.translucent)
			insetHeight += self.navigationController.toolbar.frame.size.height;
	}
	
	UIEdgeInsets contentInsets = tableView.contentInset;
	contentInsets.bottom = insetHeight;
	
	UIEdgeInsets scrollIndicatorInsets = tableView.scrollIndicatorInsets;
	scrollIndicatorInsets.bottom = insetHeight;
	
	void (^animations)(void) = ^(void)
	{
		tableView.contentInset = contentInsets;
		tableView.scrollIndicatorInsets = scrollIndicatorInsets;
	};
	
	void (^completion)(BOOL) = ^(BOOL finished)
	{
		[tableView scrollToRowAtIndexPath:tableView.indexPathForSelectedRow atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	};
	
	[UIView animateWithDuration:animationDuration delay:0.0 options:(UIViewAnimationOptions)animationCurve animations:animations completion:completion];
}

@end
