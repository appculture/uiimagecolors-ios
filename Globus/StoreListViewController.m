//
//  StoreListViewController.m
//  Globus
//
//  Created by Patrik Oprandi on 18.05.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "GlobusController.h"
#import "StoreListViewController.h"
#import "StylesheetController.h"
#import "Store.h"
#import "BorderedView.h"
#import "BorderedButtonController.h"
#import "StoreResult.h"


#define kStoreListNearbyShowStoresMaxCount 3
#define kStoreListUpdateMinimumDistance 30
#define kSuggestTableViewTypingDelay 0.5

#define kGroupAnnotationThreshold 10


@interface StoreListViewController ()

@property (nonatomic, strong) NSArray *completeStoreArray;
@property (nonatomic, strong) NSArray *storesArray;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) BorderedView *listBtn;
@property (nonatomic, strong) BorderedView *mapBtn;
@property (nonatomic, strong) MKAnnotationView *selectedAnnotationView;


- (void)loadStores;
- (void)reloadList;

- (NSArray *)storeArraySortedByDistance:(NSArray *)theStoreArray;
- (NSArray *)sectionArrayWithStoreArray:(NSArray *)theStoreArray;
- (NSArray *)indexArrayWithSectionArray:(NSArray *)theSectionArray;
- (MKCoordinateRegion)enclosingRegionForStoreArray:(NSArray *)theStoreArray;

- (void)pushOrPopoverViewController:(UIViewController *)theViewController fromRect:(CGRect)rect inView:(UIView *)theView;
- (void)dismissPopoverController;

- (void)locationControllerDidFindLocationNotification:(NSNotification *)theNotification;
- (void)locationControllerDidChangeLocationNotification:(NSNotification *)theNotification;
- (void)locationControllerDidFailWithErrorNotification:(NSNotification *)theNotification;
- (void)didUpdateStoresNotification:(NSNotification *)theNotification;

- (void)listBtnTouched;
- (void)mapBtnTouched;

- (void)initObject;
- (CLLocationDistance)distanceFromTwoCoordinates:(CLLocationCoordinate2D)coordinate1 andCoordinate:(CLLocationCoordinate2D)coordinate2;
- (Store *)closestStore;

@end


@implementation StoreListViewController

@synthesize completeStoreArray, storesArray;
@synthesize location, listBtn, mapBtn;
@synthesize selectedAnnotationView = _selectedAnnotationView;



#pragma mark - GUI startup & shutdown

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self initObject];
}

- (void)initObject
{
    [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"TabBarItem2", @"") image:[UIImage imageNamed:@"TabBarItem3"] tag:2]];
    self.title = NSLocalizedString(@"TabBarItem2", @"");
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
    // Notification center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateStoresNotification:) name:kGlobusControllerDidUpdateStoresNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationControllerDidFindLocationNotification:) name:LocationControllerDidFindLocationNotification object:nil];	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationControllerDidChangeLocationNotification:) name:LocationControllerDidChangeLocationNotification object:nil];	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationControllerDidFailWithErrorNotification:) name:LocationControllerDidFailWithErrorNotification object:nil];
    
	// Initially hide map
	storeMapView.alpha = 0.0;
    
	// infoView for locating info
	infoView = [[InfoView alloc] initWithFrame:storeTableView.frame];
    //infoView.backgroundColor = [[StylesheetController sharedInstance] colorWithKey:@"ActivityViewBackground"];
	[self.view addSubview:infoView];
	
	storeTableView.backgroundView = nil;
	
	
	BorderedView *listButton = [[BorderedButtonController sharedInstance] 
                                createBorderedViewWithName:@"TopListButton"];
    listButton.touchTreshold = 10;
    [[BorderedButtonController sharedInstance] registerTarget:self 
                                                    andAction:@selector(listBtnTouched) 
                                              forBorderedView:listButton];
    BorderedView *mapButton = [[BorderedButtonController sharedInstance] 
                               createBorderedViewWithName:@"TopMapButton"];
    mapButton.touchTreshold = 10;
    [[BorderedButtonController sharedInstance] registerTarget:self 
                                                    andAction:@selector(mapBtnTouched) 
                                              forBorderedView:mapButton];
    mapButton.frame = CGRectMake(listButton.frame.size.width,
                                 mapButton.frame.origin.y, 
                                 mapButton.frame.size.width, 
                                 mapButton.frame.size.height);
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                               0,
                                                               listButton.frame.size.width+mapButton.frame.size.width, 
                                                               listButton.frame.size.height)];
    [topView addSubview:listButton];
    [topView addSubview:mapButton];
    self.listBtn = listButton;
    self.mapBtn = mapButton;
    listBtn.buttonActive = YES;
    UIBarButtonItem *topRightBar = [[UIBarButtonItem alloc] initWithCustomView:topView];
	self.navigationItem.rightBarButtonItem = topRightBar;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	[storeTableView deselectRowAtIndexPath:storeTableView.indexPathForSelectedRow animated:YES];
    
    if ([[GlobusController sharedInstance] updatingStores]) 
    {
        [[LocationController sharedInstance] stopLocationTracking];
        [infoView showLoadingWithText:NSLocalizedString(@"LoadingText", @"")];
    } 
    else {
        if (!self.completeStoreArray) 
            [self didUpdateStoresNotification:nil];
    }
	
	self.pageName = @"stores";
	[[GlobusController sharedInstance] analyticsTrackPageview:[self.navigationController pagePath]];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[LocationController sharedInstance] stopLocationTracking];
}

- (void)viewDidUnload
{
	[super viewDidUnload];    
    
    self.completeStoreArray = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGlobusControllerWillUpdateStoresNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGlobusControllerDidUpdateStoresNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LocationControllerDidFindLocationNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:LocationControllerDidChangeLocationNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:LocationControllerDidFailWithErrorNotification object:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
	else
		return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Notifications

- (void)locationControllerDidFindLocationNotification:(NSNotification *)theNotification
{
	[self reloadList];
	
	[storeMapView setRegion:[self enclosingRegionForStoreArray:storesArray] animated:NO];
	[infoView hideAnimated:YES];
}   

- (void)locationControllerDidChangeLocationNotification:(NSNotification *)theNotification
{
	// Only update view if distance changed by more than 30m
	if (!location || [location distanceFromLocation:[LocationController sharedInstance].currentLocation] > kStoreListUpdateMinimumDistance)
	{
		[self reloadList];
        
        if ([storesArray count] > 0)
            [storeMapView setRegion:[self enclosingRegionForStoreArray:storesArray] animated:YES];
	}
}

- (void)locationControllerDidFailWithErrorNotification:(NSNotification *)theNotification
{
	[infoView hideAnimated:YES];
}

- (void)didUpdateStoresNotification:(NSNotification *)theNotification
{
    [[GlobusController sharedInstance] setUpdatingStores:NO];
    
    [infoView hideAnimated:YES];
    
    self.completeStoreArray = [[GlobusController sharedInstance] storeArray];
    [self loadStores];
    
#if !TARGET_IPHONE_SIMULATOR    
    if ([[LocationController sharedInstance] locationServicesEnabled])
	{
		[[LocationController sharedInstance] startLocationTracking];
		storeMapView.showsUserLocation = YES;
        
		if (![[LocationController sharedInstance] isLocationValid])
			[infoView showLoadingWithText:NSLocalizedString(@"Locations.UpdatingText", @"")];
	}
#endif
}


- (void)loadStores 
{
    if (storesArray) 
		[storeMapView removeAnnotations:storeMapView.annotations];
	
	self.completeStoreArray = [[GlobusController sharedInstance] storeArray];    
	[self reloadList];
	
	if ([storesArray count] > 0)
	{
		[storeMapView addAnnotations:storesArray];
		[storeMapView setRegion:[self enclosingRegionForStoreArray:storesArray] animated:NO];
	}
}


#pragma mark - static Helper functions

static NSInteger sectionTitleSort(id sectionDict1, id sectionDict2, void *context)
{
	NSString *title1 = [sectionDict1 valueForKey:@"name"];
	NSString *title2 = [sectionDict2 valueForKey:@"name"];
	
	return [title1 caseInsensitiveCompare:title2];
}

static NSInteger distanceSort(id store1, id store2, void *context)
{
	CLLocationDistance distance1 = ((Store *)store1).distance;
	CLLocationDistance distance2 = ((Store *)store2).distance;
    
	if (distance1 < distance2)
		return NSOrderedAscending;
	
	if (distance1 > distance2)
		return NSOrderedDescending;
    
	return NSOrderedSame;
}


#pragma mark - Private API methods

- (void)reloadList
{
	self.location = [LocationController sharedInstance].currentLocation;
    self.storesArray = [self storeArraySortedByDistance:completeStoreArray];
    
	storeTableView.sectionArray = [self sectionArrayWithStoreArray:storesArray];
	storeTableView.indexArray = [self indexArrayWithSectionArray:storeTableView.sectionArray];
	
	[storeTableView reloadData];
}

- (NSArray *)storeArraySortedByDistance:(NSArray *)theStoreArray
{
	NSMutableArray *array = [[NSMutableArray alloc] init];
    
    int index = 0;
    for (Store *store in theStoreArray)
	{
        //store.distance = [store.location distanceFromLocation:location];
		Store *s = [[Store alloc] initWithStore:store location:location];
        [array addObject:s];
        index++;
	}
    
	// No sorting needed
	if (![LocationController sharedInstance].isLocationValid)
		return array;
    
	NSArray *sortedArray = [array sortedArrayUsingFunction:distanceSort context:nil];
	
	return sortedArray;
}

- (NSArray *)sectionArrayWithStoreArray:(NSArray *)theStoreArray
{
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	NSMutableDictionary *sectionDict;
	NSMutableArray *storeArray;
	
	for (Store *store in theStoreArray)
	{
		sectionDict = nil;
        
		NSString *title;
		if ([[LocationController sharedInstance] isLocationValid])
		{
            if (store.distance > 100000)
				title = @"> 100 km";
			else if (store.distance > 50000)
				title = @"50 - 100 km";
			else if (store.distance > 20000)
				title = @"20 - 50 km";
			else if (store.distance > 10000)
				title = @"10 - 20 km";
			else if (store.distance > 5000)
				title = @"5 - 10 km";
			else if (store.distance > 1000)
				title = @"1 - 5 km";
			else
				title = @"< 1 km";
		}
		else {
			title = store.city;
        }
		
		for (NSMutableDictionary *existingSectionDict in array)
			if ([[existingSectionDict valueForKey:@"name"] isEqualToString:title])
			{
				sectionDict = existingSectionDict;
				break;
			}
		
		if (sectionDict)
			storeArray = [sectionDict objectForKey:@"stores"];
		else
		{
			sectionDict = [[NSMutableDictionary alloc] init];
			[array addObject:sectionDict];
			[sectionDict setValue:title forKey:@"name"];
			[sectionDict setValue:[[title substringToIndex:1] uppercaseString] forKey:@"index"];
			storeArray = [[NSMutableArray alloc] init];
			[sectionDict setObject:storeArray forKey:@"stores"];
		}
		[storeArray addObject:store];
	}
	
	// Already sorted by distance
	if ([[LocationController sharedInstance] isLocationValid])
		return array;
	
	NSArray *sortedArray = [array sortedArrayUsingFunction:sectionTitleSort context:nil];
	
	return sortedArray;
}

- (NSArray *)indexArrayWithSectionArray:(NSArray *)theSectionArray
{
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (NSDictionary *sectionDict in theSectionArray)
	{
		NSString *indexString = [sectionDict valueForKey:@"index"];
		
		if (![array containsObject:indexString])
			[array addObject:indexString];
	}
	
	return array;
}

- (MKCoordinateRegion)enclosingRegionForStoreArray:(NSArray *)theStoreArray
{
	CLLocationCoordinate2D min = {90.0, 180.0}, max = {-90.0, -180.0};
	
	NSUInteger maxCount = [theStoreArray count];
	
	if ([[LocationController sharedInstance] isLocationValid])
	{
		min.latitude = fmin(min.latitude, location.coordinate.latitude);
		min.longitude = fmin(min.longitude, location.coordinate.longitude);
		max.latitude = fmax(max.latitude, location.coordinate.latitude);
		max.longitude = fmax(max.longitude, location.coordinate.longitude);
		
		maxCount = kStoreListNearbyShowStoresMaxCount;
	}
	
    NSUInteger count = 0;
    for (Store *store in theStoreArray)
    {
        min.latitude = fmin(min.latitude, store.location.coordinate.latitude);
        min.longitude = fmin(min.longitude, store.location.coordinate.longitude);
        max.latitude = fmax(max.latitude, store.location.coordinate.latitude);
        max.longitude = fmax(max.longitude, store.location.coordinate.longitude);
        if (count++ > maxCount)
            break;
    }
	
	MKCoordinateRegion region;
	region.center.latitude = min.latitude + (max.latitude - min.latitude) / 2.0;
	region.center.longitude = min.longitude + (max.longitude - min.longitude) / 2.0;
	region.span.latitudeDelta = max.latitude - min.latitude;
	region.span.longitudeDelta = max.longitude - min.longitude;
	
	return region;
}

- (void)pushOrPopoverViewController:(UIViewController *)theViewController fromRect:(CGRect)rect inView:(UIView *)theView
{
//	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//	{
//		if (!viewPopoverController)
//		{
//			viewPopoverController = [[UIPopoverController alloc] initWithContentViewController:theViewController];
//			viewPopoverController.delegate = self;
//			viewPopoverController.popoverContentSize = CGSizeMake(self.contentSizeForViewInPopover.width, self.contentSizeForViewInPopover.height / 2.0);
//			[viewPopoverController presentPopoverFromRect:rect inView:theView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//		}
//		else
//			[self dismissPopoverController];
//	}
//	else
		[self.navigationController pushViewController:theViewController animated:YES];	
}

- (void)dismissPopoverController
{
	if (viewPopoverController)
	{
		[storeTableView deselectRowAtIndexPath:storeTableView.indexPathForSelectedRow animated:YES];
		[viewPopoverController dismissPopoverAnimated:YES];
		viewPopoverController = nil;
	}	
}


#pragma mark - PopoverController delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[storeTableView deselectRowAtIndexPath:storeTableView.indexPathForSelectedRow animated:YES];
	viewPopoverController = nil;
}


#pragma mark - StoreTableView delegate

- (void)storeTableView:(StoreTableView *)tableView didSelectStore:(Store *)theStore
{
	storeViewController.store = theStore;
	[self pushOrPopoverViewController:storeViewController fromRect:[storeTableView rectForRowAtIndexPath:[storeTableView indexPathForSelectedRow]] inView:storeTableView];
}


#pragma mark - UISearchDisplay delegates

- (void)listBtnTouched
{
	[UIView animateWithDuration:0.3 
						  delay:0.0 
						options:UIViewAnimationOptionCurveEaseOut 
					 animations:^ {
						 storeMapView.alpha = 0.0;
					 } 
					 completion:^(BOOL finished) {
						 [[GlobusController sharedInstance] analyticsTrackEvent:@"Stores" action:@"Click" label:@"List" value:@0];
					 }
	 ];
    listBtn.buttonActive = YES;
	mapBtn.buttonActive = NO;
}

- (void)mapBtnTouched
{
	[UIView animateWithDuration:0.3 
						  delay:0.0 
						options:UIViewAnimationOptionCurveEaseOut 
					 animations:^ {
						 storeMapView.alpha = 1.0;
					 } 
					 completion:^(BOOL finished) {
						 [[GlobusController sharedInstance] analyticsTrackEvent:@"Stores" action:@"Click" label:@"Map" value:@0];
					 }
	 ];
	mapBtn.buttonActive = YES;
	listBtn.buttonActive = NO;
    
    if(storeMapView.selectedAnnotations == nil || storeMapView.selectedAnnotations.count == 0) {
        Store *closestStore = [self closestStore];
        if(closestStore) {
            [storeMapView selectAnnotation:closestStore animated:NO];
        }
    }
}


#pragma mark - MKMapViewDelegate

//- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
//{
//	if (storesArray.count > 0)
//		[storeMapView selectAnnotation:[storesArray objectAtIndex:0] animated:YES];
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	static NSString *storeStockPinID = @"StorePinID";
	
	if ([annotation isKindOfClass:[Store class]])
	{
		MKAnnotationView *pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:storeStockPinID];
		
		if (!pinView)
		{
			pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:storeStockPinID];
			pinView.canShowCallout = YES;
			pinView.image = [UIImage imageNamed:@"Pin.png"];
			pinView.centerOffset = CGPointMake(-7.0, -1.0);
			pinView.calloutOffset = CGPointZero;
			pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		}
        else
			pinView.annotation = annotation;
		
		return pinView;
    }
	
	return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	Store *store = (Store *)view.annotation;
	
	storeViewController.store = store;
	[self pushOrPopoverViewController:storeViewController fromRect:[storeTableView rectForRowAtIndexPath:[storeTableView indexPathForSelectedRow]] inView:storeTableView];
}
/*
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView {
    id<MKAnnotation> annotation = aView.annotation;
    if (!annotation || ![aView isSelected])
        return;
    if ( NO == [annotation isKindOfClass:[MultiRowCalloutCell class]] &&
        [annotation conformsToProtocol:@protocol(MultiRowAnnotationProtocol)] )
    {
        NSObject <MultiRowAnnotationProtocol> *pinAnnotation = (NSObject <MultiRowAnnotationProtocol> *)annotation;
        if (!self.calloutAnnotation) {
            _calloutAnnotation = [[MultiRowAnnotation alloc] init];
            [_calloutAnnotation copyAttributesFromAnnotation:pinAnnotation];
            [mapView addAnnotation:_calloutAnnotation];
        }
        self.selectedAnnotationView = aView;
        return;
    }
    [mapView setCenterCoordinate:annotation.coordinate animated:YES];
    self.selectedAnnotationView = aView;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)aView {
    if ( NO == [aView.annotation conformsToProtocol:@protocol(MultiRowAnnotationProtocol)] )
        return;
    if ([aView.annotation isKindOfClass:[MultiRowAnnotation class]])
        return;
    GenericPinAnnotationView *pinView = (GenericPinAnnotationView *)aView;
    if (self.calloutAnnotation && !pinView.preventSelectionChange) {
        [mapView removeAnnotation:_calloutAnnotation];
        self.calloutAnnotation = nil;
    }
}
*/
- (CLLocationDistance)distanceFromTwoCoordinates:(CLLocationCoordinate2D)coordinate1 andCoordinate:(CLLocationCoordinate2D)coordinate2 {
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:coordinate1.latitude longitude:coordinate1.longitude];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:coordinate2.latitude longitude:coordinate2.longitude];
    return [loc1 distanceFromLocation:loc2];
}
     
- (Store *)closestStore
{
    if(![LocationController sharedInstance].isLocationValid) {
        return nil;
    }
    CLLocationDistance minDistance = DBL_MAX;
    Store *closestStore = nil;
    CLLocation *currentLocation = [[LocationController sharedInstance] currentLocation];
    for(Store *s in storesArray) {
		CLLocation *locOfStore = [[CLLocation alloc] initWithLatitude:s.coordinate.latitude longitude:s.coordinate.longitude];
		CLLocationDistance currDistance = [currentLocation distanceFromLocation:locOfStore];
		if(currDistance < minDistance) {
			minDistance = currDistance;
			closestStore = s;
        }
    }
    return closestStore;
}


@end
