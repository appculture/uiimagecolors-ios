//
//  CustomCellFormViewController.m
//  Globus
//
//  Created by Mladen Djordjevic on 3/6/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "CustomCellFormViewController.h"
#import "UICellBackgroundView.h"
#import "PickerFormfieldCell.h"
#import "TextFormfieldCell.h"
#import "GlobusController.h"
#import "BorderedView.h"


#define kCellBackgroundColor [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]
#define kCellSelectedBackgroundColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define kCellBorderColor [UIColor colorWithRed:207.0/255.0 green:207.0/255.0 blue:207.0/255.0 alpha:1.0]
#define kCellCornerRadius 0.0
#define kCellIndentation 7.0

@interface CustomCellFormViewController ()

@property (nonatomic, strong) FormfieldCell *selectedCell;

- (void)deselectCell;
- (void)selectCell;

- (void)additionalPickerWillHide:(NSNotification *)theNotification;

@end

@implementation CustomCellFormViewController

@synthesize selectedCell;


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	
    id leftView = self.navigationItem.leftBarButtonItem.customView;
    if([[leftView class] isSubclassOfClass:[BorderedView class]]) {
        [leftView setAlpha:0.0];
    }
    id rightView = self.navigationItem.rightBarButtonItem.customView;
    if([[rightView class] isSubclassOfClass:[BorderedView class]]) {
        [rightView setAlpha:0.0];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    id leftView = self.navigationItem.leftBarButtonItem.customView;
    if([[leftView class] isSubclassOfClass:[BorderedView class]]) {
        [leftView setAlpha:1.0];
    }
    id rightView = self.navigationItem.rightBarButtonItem.customView;
    if([[rightView class] isSubclassOfClass:[BorderedView class]]) {
        [rightView setAlpha:1.0];
    }

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(additionalPickerWillHide:) name:PickerFormfieldCellPickerWillHideNotification object:nil];

	self.tableView.backgroundView = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PickerFormfieldCellPickerWillHideNotification object:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
	else
		return UIInterfaceOrientationMaskPortrait;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *sectionDictionary = [formfieldArray objectAtIndex:indexPath.section];
	NSArray *rows = [sectionDictionary valueForKey:@"Rows"];
	NSDictionary *rowDic = (NSDictionary *)[rows objectAtIndex:indexPath.row];
	
	UITableViewCell *cell = [self formViewController:self cellForFormfield:rowDic];
    cell.backgroundColor = [UIColor clearColor];
	
	UICellBackgroundView *bg = [[UICellBackgroundView alloc] init];
	UICellBackgroundView *selBg = [[UICellBackgroundView alloc] init];
	
	if ([[rowDic valueForKey:@"Type"] isEqualToString:@"Button"] && [[rowDic valueForKey:@"WhiteButton"] boolValue])
	{
		bg.fillColor = kCellSelectedBackgroundColor;
		bg.cornerRadius = kCellCornerRadius;
		bg.borderColor = kCellBorderColor;
		bg.indentX = kCellIndentation;
		
		selBg.fillColor = kCellBackgroundColor;
		selBg.cornerRadius = kCellCornerRadius;
		selBg.borderColor = kCellBorderColor;
		selBg.indentX = kCellIndentation;
	} else
	{
		bg.fillColor = kCellBackgroundColor;
		bg.cornerRadius = kCellCornerRadius;
		bg.borderColor = kCellBorderColor;
		bg.indentX = kCellIndentation;
		
		selBg.fillColor = kCellSelectedBackgroundColor;
		selBg.cornerRadius = kCellCornerRadius;
		selBg.borderColor = kCellBorderColor;
		selBg.indentX = kCellIndentation;
	}
        
    cell.backgroundView = bg;
    cell.selectedBackgroundView = selBg;
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    UICellBackgroundViewPosition bgPosition;
    if(indexPath.row == 0){
        if(indexPath.row == [rows count]-1){
            bgPosition = UICellBackgroundViewPositionSingle;
        } else {
            bgPosition = UICellBackgroundViewPositionTop;
        }
    } else if(indexPath.row == [rows count]-1){
        bgPosition = UICellBackgroundViewPositionBottom;
    } else {
        bgPosition = UICellBackgroundViewPositionMiddle;
    }
    bg.position = bgPosition;
    selBg.position = bgPosition;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionDictionary = [formfieldArray objectAtIndex:section];
	NSArray *rowArray = [sectionDictionary valueForKey:@"Rows"];
	
	return rowArray.count;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *sectionDictionary = [formfieldArray objectAtIndex:indexPath.section];
	NSArray *rowArray = [sectionDictionary valueForKey:@"Rows"];
	NSDictionary *rowDictionary = (NSDictionary *)[rowArray objectAtIndex:indexPath.row];
	
	NSString *type = [rowDictionary valueForKey:@"Type"];
	if ([type isEqualToString:@"Text"])
		return [TextFormfieldCell heightForFormfieldDictionary:rowDictionary valueDictionary:valueDictionary];
	if ([type isEqualToString:@"Button"] && [[rowDictionary valueForKey:@"WhiteButton"] boolValue])
	{
		if ([[GlobusController sharedInstance] is_iPad])
			return 52.0;
		else
			return 36.0;
	}
	
	if ([[GlobusController sharedInstance] is_iPad])
		return 56.0;
	else
		return theTableView.rowHeight;
}

- (void)formfieldCellDidBeginEditing:(FormfieldCell *)formfieldCell
{
	[self deselectCell];
	
	[super formfieldCellDidBeginEditing:formfieldCell];
	
	selectedCell = formfieldCell;
	
	[self selectCell];
}

- (void)formfieldCellDidEndEditing:(FormfieldCell *)formfieldCell
{
	[self deselectCell];
	
	[super formfieldCellDidEndEditing:formfieldCell];
}

- (void)deselectCell
{
    UICellBackgroundView *bg = (UICellBackgroundView *)selectedCell.backgroundView;
    bg.fillColor = kCellBackgroundColor;
	
	[bg setNeedsDisplay];
}

- (void)selectCell
{
	UICellBackgroundView *bg = (UICellBackgroundView *)selectedCell.backgroundView;
    bg.fillColor = kCellSelectedBackgroundColor;
	
	[bg setNeedsDisplay];
}

- (void)additionalPickerWillHide:(NSNotification *)theNotification
{
	[self deselectCell];
}

- (BOOL)isModal { 
	NSArray *viewControllers = [[self navigationController] viewControllers];
	UIViewController *rootViewController = [viewControllers objectAtIndex:0];    
	return rootViewController == self;
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
		} else {
			FormfieldCell *oldCell = (FormfieldCell *)self.selectedCell;
			[oldCell endEditing];
		}
		
		if ([cell canBecomeFirstResponder])
			[cell becomeFirstResponder];
		else
			[self endEditing];
	}
}


@end
