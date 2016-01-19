//
//  StoreTableView.m
//  Globus
//
//  Created by Patrik Oprandi on 18.05.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "StoreTableView.h"
#import "StylesheetController.h"
#import "LocationDistanceCell.h"
#import "Store.h"
#import "GlobusSectionHeaderView.h"
#import "GlobusController.h"

@interface StoreTableView ()

- (void)initObject;

@end


@implementation StoreTableView

@synthesize sectionArray, indexArray, nextDelegate;


#pragma mark - Housekeeping

- (void)initObject
{
	self.delegate = self;
	self.dataSource = self;
	
	self.sectionIndexBackgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	if (self)
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

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
	NSDictionary *sectionDict = [sectionArray objectAtIndex:section];
	NSArray *storeArray = [sectionDict objectForKey:@"stores"];
	
	return storeArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSDictionary *sectionDict = [sectionArray objectAtIndex:section];
    
	return [sectionDict valueForKey:@"name"];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	CGFloat headerHeight = 30;
    CGFloat labelX = 20;
    CGFloat labelY = 5;
    if([[GlobusController sharedInstance] is_iPad]){
        headerHeight = 60;
        labelX = 55;
        labelY = 20;
    }
    GlobusSectionHeaderView *headerSectionView = [[GlobusSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, headerHeight)];
    headerSectionView.headerLabel.frame = CGRectMake(labelX, labelY, headerSectionView.headerLabel.frame.size.width, headerSectionView.headerLabel.frame.size.height);
	NSDictionary *sectionDict = [sectionArray objectAtIndex:section];
    headerSectionView.headerLabel.text = [sectionDict valueForKey:@"name"]; 
    headerSectionView.backgroundColor = [UIColor clearColor];
    return headerSectionView;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if([[GlobusController sharedInstance] is_iPad])
		return 60.0;
	else
		return 30.0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	if (indexArray.count > 8)
		return indexArray;
	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *sectionDict = [sectionArray objectAtIndex:indexPath.section];
	NSArray *storeStockArray = [sectionDict objectForKey:@"stores"];
	
	LocationDistanceCell *cell = (LocationDistanceCell *)[theTableView dequeueReusableCellWithIdentifier:kLocationDistanceCellId];
	if (!cell)
		cell = [[LocationDistanceCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kLocationDistanceCellId];
	
	Store *store = [storeStockArray objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [NSString stringWithFormat:@"%@",store.name];
	
	if ([LocationController sharedInstance].isLocationValid)
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[GlobusController sharedInstance] distanceStringFromDouble:store.distance]];
    else
		cell.detailTextLabel.text = @"";
    
    if([storeStockArray count] == 1) {
        cell.bgPosition = UICellBackgroundViewPositionSingle;
    } else if(indexPath.row == 0) {
        cell.bgPosition = UICellBackgroundViewPositionTop;
    } else if (indexPath.row == [storeStockArray count] - 1) {
        cell.bgPosition = UICellBackgroundViewPositionBottom;
    } else {
        cell.bgPosition = UICellBackgroundViewPositionMiddle;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	NSInteger section;
	
	if (index == 0)
		tableView.contentOffset = CGPointZero;
	
	for (section = 0; section < sectionArray.count; section++)
	{
		NSDictionary *sectionDict = [sectionArray objectAtIndex:section];
		if ([title isEqualToString:[sectionDict valueForKey:@"index"]])
			break;
	}
	
	return section;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *sectionDict = [sectionArray objectAtIndex:indexPath.section];
	NSArray *storeArray = [sectionDict objectForKey:@"stores"];
	
	if ([nextDelegate respondsToSelector:@selector(storeTableView:didSelectStore:)])
		[nextDelegate storeTableView:self didSelectStore:[storeArray objectAtIndex:indexPath.row]];
}

@end
