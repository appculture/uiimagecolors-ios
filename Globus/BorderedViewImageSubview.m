//
//  BorderedViewImageSubview.m
//  Globus
//
//  Created by Mladen Djordjevic on 3/21/12.
//  Copyright (c) 2012 Youngculture. All rights reserved.
//

#import "BorderedViewImageSubview.h"

@interface BorderedViewImageSubview ()

@property (nonatomic, strong) UIImage *img;

@end

@implementation BorderedViewImageSubview

@synthesize sourceImage = _sourceImage;
@synthesize img = _img;

- (void)initObject {
    [super initObject];
    [self addObserver:self
                    forKeyPath:@"sourceImage"
                       options:NSKeyValueObservingOptionNew
                       context:NULL];
}

- (void)customDrawInRect {
    if(_img) {
        [_img drawInRect:self.frame];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( [keyPath isEqualToString:@"sourceImage"] ){
        UIImage *img = [UIImage imageNamed:_sourceImage];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, img.size.width, img.size.height);
        self.img = img;
    }
}
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"sourceImage"];
}


@end
