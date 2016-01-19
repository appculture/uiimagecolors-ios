//
//  GlobusSectionHeaderView.h
//  Globus
//
//  Created by Patrik Oprandi on 28.03.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlobusSectionHeaderView : UIView

@property (nonatomic, strong) UILabel *headerLabel;

+ (CGFloat)heightForHeaderView;

@end
