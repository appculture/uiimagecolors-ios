//
//  ABButton.m
//  Globus
//
//  Created by Patrik Oprandi on 16.02.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import "ABButton.h"


@implementation ABButton

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
	if (image)
		[super setBackgroundImage:[image stretchableImageWithLeftCapWidth:image.size.width / 2.0 topCapHeight:image.size.height / 2.0] forState:state];
}

@end
