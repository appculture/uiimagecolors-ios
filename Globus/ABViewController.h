//
//  ABViewController.h
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import <Foundation/Foundation.h>
#import "UINavigationController+PagePath.h"


@interface ABViewController : UIViewController
{
    NSString *pageName;
}

@property (nonatomic, strong) NSString *pageName;

@end
