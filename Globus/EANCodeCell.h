//
//  EANCodeCell.h
//  Globus
//
//  Created by Patrik Oprandi on 14.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIRemoteImageView.h"

extern NSString *const kEANCodeCellId;


@interface EANCodeCell : UITableViewCell <RemoteImageLoader>
{
    NSString *urlString;
}

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) UIRemoteImageView *eanCodeView;
@property (nonatomic, strong) UILabel *barCodeLabel;

@end
