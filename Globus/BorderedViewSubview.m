//
//  BorderedViewSubview.m
//  Globus
//
//  Created by Mladen Djordjevic on 3/22/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "BorderedViewSubview.h"

@implementation BorderedViewSubview

@synthesize name = _name;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initObject];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initObject];
    }
    return self;
}
- (id)init {
    self = [super init];
    if(self){
        [self initObject];
    }
    return self;
    
}
-(void)initObject {
    
}

@end
