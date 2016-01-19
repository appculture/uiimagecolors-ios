//
//  UINavigationController+PagePath.m
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import "UINavigationController+PagePath.h"
#import "ABViewController.h"


@implementation UINavigationController (PagePath)

- (NSString *)pagePath
{
	NSMutableString *pagePath = [[NSMutableString alloc] initWithFormat:@"/%@", [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0]]; 
	
	for (ABViewController *viewController in self.viewControllers)
		if ([viewController isKindOfClass:[ABViewController class]] && viewController.pageName && viewController.pageName.length > 0)
			[pagePath appendFormat:@"/%@", viewController.pageName];
	
	return pagePath;
}

@end
