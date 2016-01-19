//
//  TrackingTableViewController.h
//  Globus
//
//  Created by Patrik Oprandi on 24.06.14.
//
//

#import "UINavigationController+PagePath.h"


@interface TrackingTableViewController : UITableViewController
{
    NSString *pageName;
}

@property (nonatomic, strong) NSString *pageName;

@end
