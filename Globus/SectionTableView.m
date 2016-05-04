//
//  SectionTableView.m
//  Globus
//
//  Created by Patrik Oprandi on 28.03.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "GlobusController.h"
#import "SectionTableView.h"
#import "StylesheetController.h"
#import "GlobusSectionHeaderView.h"
#import "GlobusSectionHeaderInfoView.h"
#import "ButtonCell.h"
#import "PropertyCell.h"
#import "UICellBackgroundView.h"

#define kCellBackgroundColor [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]
#define kCellSelectedBackgroundColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define kCellBorderColor [UIColor colorWithRed:207.0/255.0 green:207.0/255.0 blue:207.0/255.0 alpha:1.0]
#define kCellCornerRadius 0.0
#define kCellIndentation 7.0
#define kiPhoneFontSize 16.0
#define kiPadFontSize 22


@interface SectionTableView ()

- (void)initObject;

- (void)drawCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath rows:(NSUInteger)rows;

@end


@implementation SectionTableView

@synthesize sectionArray, nextDelegate;


#pragma mark - Housekeeping

- (void)initObject
{
	self.delegate = self;
	self.dataSource = self;
	
    self.backgroundColor = [[StylesheetController sharedInstance] colorWithKey:@"GroupedTableViewBackground"];
	
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
		[self initObject];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
		[self initObject];
	
	return self;
}

- (void)awakeFromNib
{
	[self initObject];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
	NSDictionary *sectionDictionary = [sectionArray objectAtIndex:section];
	NSArray *rowArray = [sectionDictionary valueForKey:@"Rows"];
	
	return rowArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSDictionary *sectionDictionary = [sectionArray objectAtIndex:section];
	
	return NSLocalizedString([sectionDictionary valueForKey:@"Header"], @"");
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSDictionary *sectionDictionary = [sectionArray objectAtIndex:section];
	
	return [sectionDictionary valueForKey:@"Footer"];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionDictionary = [sectionArray objectAtIndex:section];
    
    if ([sectionDictionary valueForKey:@"Header"]) 
    {
        GlobusSectionHeaderView *headerSectionView = [[GlobusSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50.0)];
        headerSectionView.headerLabel.text = NSLocalizedString([sectionDictionary valueForKey:@"Header"], @"");
        return headerSectionView;
    } else {
		if ([sectionDictionary valueForKey:@"HeaderLittle"]) 
		{
			GlobusSectionHeaderInfoView *headerSectionView = [[GlobusSectionHeaderInfoView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 60.0)];
			headerSectionView.headerLabel.text = NSLocalizedString([sectionDictionary valueForKey:@"HeaderLittle"], @"");
			return headerSectionView;
		}
	}
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (section == 0)
		return [GlobusSectionHeaderView heightForHeaderView];
	else if (section == 1)
		return [GlobusSectionHeaderInfoView heightForHeaderView];
	
	return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *sectionDictionary = [sectionArray objectAtIndex:indexPath.section];
	NSArray *rowArray = [sectionDictionary valueForKey:@"Rows"];
	NSDictionary *rowDictionary = (NSDictionary *)[rowArray objectAtIndex:indexPath.row];
	
	NSString *type = [rowDictionary valueForKey:@"Type"];
	if ([type isEqualToString:@"Property"] && [[rowDictionary valueForKey:@"Name"] isEqualToString:@"MapButton"])
	{
		return [PropertyCell heightForType:[rowDictionary valueForKey:@"TypeLabel"] value:[rowDictionary valueForKey:@"ValueLabel"] accessory:([rowDictionary valueForKey:@"Accessory"] != nil)];
	}
	else if ([nextDelegate respondsToSelector:@selector(sectionTableView:heightForRow:)])
		return [nextDelegate sectionTableView:self heightForRow:rowDictionary];
	
	if ([[GlobusController sharedInstance] is_iPad])
		return 56.0;
	else
		return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *sectionDictionary = [sectionArray objectAtIndex:indexPath.section];
	NSArray *rowArray = [sectionDictionary valueForKey:@"Rows"];
	NSDictionary *rowDictionary = (NSDictionary *)[rowArray objectAtIndex:indexPath.row];
	
	NSString *type = [rowDictionary valueForKey:@"Type"];
	if ([type isEqualToString:@"Button"])
	{
		ButtonCell *cell = (ButtonCell *)[theTableView dequeueReusableCellWithIdentifier:kButtonCellID];
		if (!cell)
			cell = [[ButtonCell alloc] initWithStyle:UITableViewCellStyleDefault];
		
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		
		[self drawCell:cell indexPath:indexPath rows:[rowArray count]];
		
		cell.textLabel.text = NSLocalizedString([rowDictionary valueForKey:@"LabelKey"], @"");
        cell.textLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"PropertyValueText"];
        cell.textLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize];
		cell.imageView.image = [[StylesheetController sharedInstance] imageWithKey:[rowDictionary valueForKey:@"IconName"]];
		cell.imageView.highlightedImage = [[StylesheetController sharedInstance] imageWithKey:[rowDictionary valueForKey:@"IconHighlightedName"]];
		
		NSString *accessory = [rowDictionary valueForKey:@"Accessory"];
		if ([accessory isEqualToString:@"DisclosureIndicator"])
		{
			[cell setAccessory:ButtonCellAccessoryDisclosureIndicator];
			cell.textAlignment = NSTextAlignmentLeft;
		}
		else if ([accessory isEqualToString:@"LoadingIndicator"])
		{
			[cell setAccessory:ButtonCellAccessoryDisclosureIndicator];
			cell.textAlignment = NSTextAlignmentCenter;
		}
		else
		{
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.textAlignment = NSTextAlignmentCenter;
		}
		
		return cell;
	}
	else if ([type isEqualToString:@"Property"])
	{
		PropertyCell *cell = (PropertyCell *)[theTableView dequeueReusableCellWithIdentifier:kPropertyCellID];
		if (!cell)
			cell = [[PropertyCell alloc] init];
		
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		
		[self drawCell:cell indexPath:indexPath rows:[rowArray count]];
		
		cell.textLabel.text = NSLocalizedString([rowDictionary valueForKey:@"TypeLabel"], @"");
		cell.detailTextLabel.text = NSLocalizedString([rowDictionary valueForKey:@"ValueLabel"], @"");
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        
		NSString *accessory = [rowDictionary valueForKey:@"Accessory"];
		if ([accessory isEqualToString:@"DisclosureIndicator"]) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if ([accessory isEqualToString:@"DisclosureCustom"])
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            NSString *accessoryImage = [rowDictionary valueForKey:@"AccessoryImage"];
            if (accessoryImage != nil)
				cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryImage] highlightedImage:[UIImage imageNamed:accessoryImage]];
            else            
                cell.accessoryView = [[UIImageView alloc] initWithImage:[[StylesheetController sharedInstance] imageWithKey:@"DisclosureIndicator"] highlightedImage:[[StylesheetController sharedInstance] imageWithKey:@"DisclosureIndicatorHighlighted"]];
        } 
        else {
			cell.accessoryType = UITableViewCellAccessoryNone;
        }
		return cell;
	}
   	else if ([nextDelegate respondsToSelector:@selector(sectionTableView:cellForRow:)])
        return [nextDelegate sectionTableView:self cellForRow:rowDictionary];
	
	return nil;
}

- (void)drawCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath rows:(NSUInteger)rows
{
	UICellBackgroundView *bg = [[UICellBackgroundView alloc] init];
	UICellBackgroundView *selBg = [[UICellBackgroundView alloc] init];
	
	bg.fillColor = kCellBackgroundColor;
	bg.cornerRadius = kCellCornerRadius;
	bg.borderColor = kCellBorderColor;
	bg.indentX = kCellIndentation;
		
	selBg.fillColor = kCellSelectedBackgroundColor;
	selBg.cornerRadius = kCellCornerRadius;
	selBg.borderColor = kCellBorderColor;
	selBg.indentX = kCellIndentation;
		
    cell.backgroundView = bg;
    cell.selectedBackgroundView = selBg;
    //cell.contentView.backgroundColor = [UIColor clearColor];
    
    UICellBackgroundViewPosition bgPosition;
    if(indexPath.row == 0){
        if(indexPath.row == rows-1){
            bgPosition = UICellBackgroundViewPositionSingle;
        } else {
            bgPosition = UICellBackgroundViewPositionTop;
        }
    } else if(indexPath.row == rows-1){
        bgPosition = UICellBackgroundViewPositionBottom;
    } else {
        bgPosition = UICellBackgroundViewPositionMiddle;
    }
    bg.position = bgPosition;
    selBg.position = bgPosition;
}


#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *sectionDictionary = [sectionArray objectAtIndex:indexPath.section];
	NSArray *rowArray = [sectionDictionary valueForKey:@"Rows"];
	NSDictionary *rowDictionary = (NSDictionary *)[rowArray objectAtIndex:indexPath.row];
	
	if ([nextDelegate respondsToSelector:@selector(sectionTableView:willSelectRow:indexPath:)])
		return [nextDelegate sectionTableView:self willSelectRow:rowDictionary indexPath:indexPath];
	else
		return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *sectionDictionary = [sectionArray objectAtIndex:indexPath.section];
	NSArray *rowArray = [sectionDictionary valueForKey:@"Rows"];
	NSDictionary *rowDictionary = (NSDictionary *)[rowArray objectAtIndex:indexPath.row];
	
	if ([nextDelegate respondsToSelector:@selector(sectionTableView:didSelectRow:)])
		return [nextDelegate sectionTableView:self didSelectRow:rowDictionary];
}

@end
