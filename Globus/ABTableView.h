//
//  ABTableView.h
//
//  Copyright 2008-2011 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import <UIKit/UIKit.h>


@interface ABTableView : UITableView <UIScrollViewDelegate>
{
}

- (void)loadRemoteImages;

@end
