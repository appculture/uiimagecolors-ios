//
//  StoreListViewController.h
//  Globus
//
//  Created by Patrik Oprandi on 18.05.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LocationController.h"
#import "StoreTableView.h"
#import "StoreViewController.h"
#import "InfoView.h"


@interface StoreListViewController : ABViewController <StoreTableViewDelegate, UIPopoverControllerDelegate, UISearchDisplayDelegate, MKMapViewDelegate>
{
	
@private
	NSArray *completeStoreArray;
    NSArray *storesArray;
    
	CLLocation *location;
	
	InfoView *infoView;
    
	UIPopoverController *viewPopoverController;
    
	IBOutlet MKMapView *storeMapView;
    
    IBOutlet StoreTableView *storeTableView;
    IBOutlet StoreViewController *storeViewController;
}

@end
