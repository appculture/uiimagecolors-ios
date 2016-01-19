//
//  SingleTextCell.m
//  Globus
//
//  Created by Mladen Djordjevic on 3/2/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "SingleTextCell.h"
#import "UICellBackgroundView.h"
#import "GlobusController.h"

#define kiPhoneFontSize 16.0
#define kiPadFontSize 20.0

@implementation SingleTextCell

NSString *const kSingleTextCellId = @"SingleTextCellId";

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
	if (self) 
    {
        
		self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
		self.textLabel.font = [UIFont fontWithName:@"GillSansAltOne" size:[[GlobusController sharedInstance] is_iPad] ? kiPadFontSize : kiPhoneFontSize];
        
		UICellBackgroundView *bg = [[UICellBackgroundView alloc] init];
		
		bg.fillColor = [UIColor whiteColor];
		bg.cornerRadius = 0.0;
		bg.position = UICellBackgroundViewPositionSingle;
		bg.borderColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:212.0/255.0 alpha:1.0];
		bg.indentX = 7.0;
		
        UICellBackgroundView *selBg = [[UICellBackgroundView alloc] init];
        
        selBg.fillColor = [UIColor colorWithRed:27.0/255.0 green:103.0/255.0 blue:224.0/255.0 alpha:1.0];    
		selBg.cornerRadius = 0.0;
        selBg.borderColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:212.0/255.0 alpha:1.0];
        
		self.backgroundView = bg;
        self.selectedBackgroundView = selBg;
		
		self.contentView.backgroundColor = [UIColor clearColor];
	}
	
	
	
	return self;
}

@end
