//
//  GlobusSectionHeaderView.m
//  Globus
//
//  Created by Patrik Oprandi on 28.03.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "GlobusSectionHeaderView.h"
#import "StylesheetController.h"
#import "GlobusController.h"

#define kiPhoneHeaderViewPadding 11.0
#define kiPadHeaderViewPadding 45.0
#define kiPhoneFontSize 17.0
#define kiPadFontSize 24.0


@implementation GlobusSectionHeaderView

@synthesize headerLabel;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.backgroundColor = [UIColor clearColor];
        
		if ([[GlobusController sharedInstance] is_iPad])
			headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(kiPadHeaderViewPadding, 25.0, self.bounds.size.width - (kiPadHeaderViewPadding * 2), 30)];
		else
			headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(kiPhoneHeaderViewPadding, 25.0, self.bounds.size.width - (kiPhoneHeaderViewPadding * 2), 20)];
		
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize];
        headerLabel.textColor = [[StylesheetController sharedInstance] colorWithKey:@"ContactSectionHeaderText"];
        headerLabel.minimumScaleFactor = 0.8;
        headerLabel.adjustsFontSizeToFitWidth = YES;
        headerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		
        [self addSubview:headerLabel];
    }
    return self;
}

+ (CGFloat)heightForHeaderView
{
	if ([[GlobusController sharedInstance] is_iPad])
		return 68.0;
	else
		return 54.0;
}

@end
