//
//  GlobusSectionHeaderInfoView.h
//  Globus
//
//  Created by Patrik Oprandi on 10.05.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlobusSectionHeaderInfoView : UIView

@property (nonatomic, strong) UILabel *headerLabel;

+ (CGFloat)heightForHeaderView;

@end
