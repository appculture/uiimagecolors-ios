//
//  GlobusSectionHeaderInfoView.m
//  Globus
//
//  Created by Patrik Oprandi on 10.05.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "GlobusSectionHeaderInfoView.h"
#import "StylesheetController.h"
#import "GlobusController.h"

#define kiPhoneHeaderViewPadding 11.0
#define kiPadHeaderViewPadding 45.0
#define kiPhoneFontSize 14.0
#define kiPadFontSize 20.0


@implementation GlobusSectionHeaderInfoView

@synthesize headerLabel;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.backgroundColor = [UIColor clearColor];
        
		if ([[GlobusController sharedInstance] is_iPad])
			headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(kiPadHeaderViewPadding, 5.0, self.bounds.size.width - (kiPadHeaderViewPadding * 2), 60)];
		else
			headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(kiPhoneHeaderViewPadding, 5.0, self.bounds.size.width - (kiPhoneHeaderViewPadding * 2), 37.0)];
		
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize];
        headerLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"ContactSectionHeaderText"];
        headerLabel.minimumScaleFactor = 0.8;
        headerLabel.adjustsFontSizeToFitWidth = YES;
        headerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		headerLabel.numberOfLines = 0;
        
        [self addSubview:headerLabel];
    }
    return self;
}

+ (CGFloat)heightForHeaderView
{
	if ([[GlobusController sharedInstance] is_iPad])
		return 60.0;
	else
		return 45.0;
}

@end
