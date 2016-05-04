//
//  BorderedButtonController.m
//  Globus
//
//  Created by Mladen Djordjevic on 3/21/12.
//  Copyright 2012 Youngculture. All rights reserved.

#import "BorderedButtonController.h"
#import "BorderedView.h"
#import "BorderedViewSubview.h"

@interface BorderedButtonController ()

@property (nonatomic, strong) NSDictionary *buttonsDic;
@property (nonatomic, strong) NSMutableDictionary *targetsForButtons;
@property (nonatomic, strong) NSMutableDictionary *actionsForButtons;

- (CGRect)frameWithFormatedDic:(NSDictionary*)formatedDictionary;
- (CGSize)sizeForText:(NSString*)textString andFont:(UIFont*)font;
- (void)generateSubviewsForBorderedView:(BorderedView*)borderedView;
- (NSDictionary*)dataDictionaryForBorderedView:(BorderedView*)borderedView;
- (float)getLastPointForBorderedView:(BorderedView*)borderedView;
- (float)getMinxPointForBorderedView:(BorderedView*)borderedView;
- (float)leftSpaceForBorderedView:(BorderedView*)borderedView;

- (void)updateSubview:(BorderedViewSubview*)subview forBorderedView:(BorderedView*)borderedView forState:(enum BorderedButtonState)buttonState;
- (void)updateSubviewsForBorderView:(BorderedView*)borderedView withState:(enum BorderedButtonState)buttonState;
- (void)performActionOnTouchForBorderedView:(BorderedView*)borderedView;
- (void)rearrangeSubviewsForBorderedView:(BorderedView*)borderedView;

@end

@implementation BorderedButtonController

@synthesize buttonsDic = _buttonsDic;
@synthesize actionsForButtons = _actionsForButtons;
@synthesize targetsForButtons = _targetsForButtons;

#pragma mark - Singleton Methods

+ (BorderedButtonController*)sharedInstance {

	static BorderedButtonController *_sharedInstance;
	if(!_sharedInstance) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedInstance = [[super allocWithZone:nil] init];
            NSString *buttonsDicPath = [[NSBundle mainBundle] pathForResource:@"BorderedButtonsData" ofType:@"plist"];
            _sharedInstance.buttonsDic = [[NSDictionary alloc] initWithContentsOfFile:buttonsDicPath];
            _sharedInstance.actionsForButtons = [NSMutableDictionary dictionary];
            _sharedInstance.targetsForButtons = [NSMutableDictionary dictionary];
			});
		}

		return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {	

	return [self sharedInstance];
}


#pragma mark - Custom Methods

- (BorderedView*)createBorderedViewWithName:(NSString *)viewName {
    BorderedView *borderedView = [[BorderedView alloc] init];
    borderedView.name = viewName;
    NSDictionary *buttonDic = [self dataDictionaryForBorderedView:borderedView];
    if(!buttonDic) {
        return nil;
    }
    
    NSDictionary *frameData = [buttonDic objectForKey:kBBFrame];
    CGRect frame = [self frameWithFormatedDic:frameData];
    borderedView.frame = frame;
    [self generateSubviewsForBorderedView:borderedView];
    if(frame.size.width == 0){ //dinamic width
        float newWidth = [self getLastPointForBorderedView:borderedView];
        borderedView.frame = CGRectMake(borderedView.frame.origin.x, borderedView.frame.origin.y, newWidth, borderedView.frame.size.height);
    }
    borderedView.shouldRearrangeSubviews = [[buttonDic objectForKey:kBBShouldRearragne] boolValue];
    if(borderedView.shouldRearrangeSubviews) {
        [self rearrangeSubviewsForBorderedView:borderedView];
    }
    [self updateBorderedView:borderedView withState:NormalState];
    return borderedView;
}

- (void)registerTarget:(id)target andAction:(SEL)action forBorderedView:(BorderedView *)borderedView {
    if(target && action && borderedView) {
        [_targetsForButtons setObject:target forKey:[NSString stringWithFormat:@"%lu",(unsigned long)[borderedView hash]]];
        [_actionsForButtons setValue:[NSValue valueWithPointer:action] forKey:[NSString stringWithFormat:@"%lu",(unsigned long)[borderedView hash]]];
    }
}
- (void)performActionOnTouchForBorderedView:(BorderedView *)borderedView {
    if(borderedView && borderedView.name) {
        id target = [_targetsForButtons objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)[borderedView hash]]];
        SEL action = [[_actionsForButtons objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)[borderedView hash]]] pointerValue];
        if(target && action) {
            if([target respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [target performSelector:action];
#pragma clang diagnostic pop
            }
        }
    }
    
}

#pragma mark - BorderedButton updating

- (void)updateBorderedView:(BorderedView *)borderedView withState:(enum BorderedButtonState)buttonState {
    NSDictionary *buttonDic = [self dataDictionaryForBorderedView:borderedView];
    NSDictionary *normalStateDic = [[buttonDic objectForKey:kBBStates] objectForKey:[NSString stringWithFormat:@"%d",buttonState]];
    borderedView.borderColor = [self colorWithFormatedString:[normalStateDic objectForKey:kBBBorderColor]];
    borderedView.borderWidth = [[normalStateDic objectForKey:kBBBorderWidth] floatValue];
    borderedView.bgrColor= [self colorWithFormatedString:[normalStateDic objectForKey:kBBBackgroundColor]];
    [self updateSubviewsForBorderView:borderedView withState:buttonState];
    [borderedView setNeedsDisplay];
}

- (void)touchEndedWithBorderedView:(BorderedView *)borderedView withTouch:(UITouch *)touch andEvent:(UIEvent *)event {
    if(!borderedView.buttonActive) {
        [self updateBorderedView:borderedView withState:NormalState];
    }
    CGRect buttonFrame = borderedView.frame;
    if(borderedView.touchTreshold > 0) {
        CGFloat treshold = borderedView.touchTreshold;
        CGRect rectWithTreshold = CGRectMake(buttonFrame.origin.x-treshold, buttonFrame.origin.y-treshold, buttonFrame.size.width + 2*treshold, buttonFrame.size.height + 2*treshold);
        buttonFrame = rectWithTreshold;
    }
    
    if(CGRectContainsPoint(buttonFrame, [touch locationInView:borderedView.superview])){
        [self performActionOnTouchForBorderedView:borderedView];
    }
}
- (void)touchStartedWithBorderedView:(BorderedView *)borderedView withTouch:(UITouch *)touch andEvent:(UIEvent *)event {
    [self updateBorderedView:borderedView withState:TouchedState];
}
- (void)touchCanceledWithBorderedView:(BorderedView *)borderedView withTouch:(UITouch *)touch andEvent:(UIEvent *)event {
    if(!borderedView.buttonActive) {
        [self updateBorderedView:borderedView withState:NormalState];
    }
}

- (void)updateSubview:(BorderedViewSubview*)subview forBorderedView:(BorderedView*)borderedView forState:(enum BorderedButtonState)buttonState {
    NSArray *subviews = [[_buttonsDic objectForKey:borderedView.name] objectForKey:kBBSubviews];
    for(NSDictionary *subviewData in subviews){
        if([subview.name isEqualToString:[subviewData objectForKey:kBBName]]){
            NSDictionary *buttonStateDic = [[subviewData objectForKey:kBBStates] objectForKey:[NSString stringWithFormat:@"%d",buttonState]];
            for(NSString *propertyKey in [buttonStateDic allKeys]){
                [subview setValue:[buttonStateDic objectForKey:propertyKey] forKey:propertyKey];
            }
            [subview setNeedsDisplay];
            return;
        }
        
    }
}
- (void)updateSubviewsForBorderView:(BorderedView*)borderedView withState:(enum BorderedButtonState)buttonState {
    for(id subview in borderedView.artificiallSubviews) {
        if([[subview class] isSubclassOfClass:[BorderedViewSubview class]]){
            [self updateSubview:subview forBorderedView:borderedView forState:buttonState];
        }
    }
}
- (void)rearrangeSubviewsForBorderedView:(BorderedView *)borderedView {
    float currMinX = [self getMinxPointForBorderedView:borderedView];
    float diff = [self leftSpaceForBorderedView:borderedView] - currMinX;
    for(BorderedViewSubview *subview in borderedView.artificiallSubviews) {
        subview.frame = CGRectMake(subview.frame.origin.x+diff, subview.frame.origin.y, subview.frame.size.width, subview.frame.size.height);
    }
}

#pragma mark - Helper methods

- (UIColor*)colorWithFormatedString:(NSString*)formatedString {
    NSArray *arrayOfComponents = [formatedString componentsSeparatedByString:@","];
    if([arrayOfComponents count] < 4) {
        return nil;
    }
    float r = [[arrayOfComponents objectAtIndex:0] intValue] / 255.0;
    float g = [[arrayOfComponents objectAtIndex:1] intValue] / 255.0;
    float b = [[arrayOfComponents objectAtIndex:2] intValue] / 255.0;
    float a = [[arrayOfComponents objectAtIndex:3] intValue];
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}
- (CGRect)frameWithFormatedDic:(NSDictionary *)formatedDictionary {
    CGRect frame;
    
    if ([formatedDictionary objectForKey:kBBButtonCount] != nil) {
        float tableWidth = [UIScreen mainScreen].bounds.size.width;
        float count = [[formatedDictionary objectForKey:kBBButtonCount] floatValue];
        float buttonWidth = (tableWidth - 30.0)  / count;
        int position = [[formatedDictionary objectForKey:kBBButtonPosition] intValue];
        float x = 15.0 + (buttonWidth * position);
        
        frame = CGRectMake(
                           x,
                           [formatedDictionary objectForKey:kBBY] ? [[formatedDictionary objectForKey:kBBY] floatValue] : 0,
                           buttonWidth,
                           [formatedDictionary objectForKey:kBBHeight] ? [[formatedDictionary objectForKey:kBBHeight] floatValue] : 0);
    } else {
        frame = CGRectMake(
                           [formatedDictionary objectForKey:kBBX] ? [[formatedDictionary objectForKey:kBBX] floatValue] : 0,
                           [formatedDictionary objectForKey:kBBY] ? [[formatedDictionary objectForKey:kBBY] floatValue] : 0,
                           [formatedDictionary objectForKey:kBBWidth] ? [[formatedDictionary objectForKey:kBBWidth] floatValue] : 0,
                           [formatedDictionary objectForKey:kBBHeight] ? [[formatedDictionary objectForKey:kBBHeight] floatValue] : 0);
    }
    return frame;
}
- (CGSize)sizeForText:(NSString *)textString andFont:(UIFont *)font {
	return [textString boundingRectWithSize:(CGSize){MAXFLOAT, MAXFLOAT} options:kNilOptions attributes:@{NSFontAttributeName:font} context:nil].size;
}
- (NSDictionary*)dataDictionaryForBorderedView:(BorderedView *)borderedView {
    NSDictionary *buttonDic = [_buttonsDic objectForKey:borderedView.name];
    if(!buttonDic) {
        for(NSDictionary *buttonDataDic in [_buttonsDic allValues]){
            NSArray *subviewDataArr = [buttonDataDic objectForKey:kBBSubviews];
            for(NSDictionary *subData in subviewDataArr) {
                if([borderedView.name isEqualToString:[subData objectForKey:kBBName]]) {
                    return subData;
                }
            }
        }
    }
    return buttonDic;
}
- (float)getLastPointForBorderedView:(BorderedView *)borderedView {
    float newWidth = 0;
    for(id subview in borderedView.artificiallSubviews){
        CGRect tmpFrame = [subview frame];
        if(tmpFrame.origin.x + tmpFrame.size.width > newWidth){
            newWidth = tmpFrame.origin.x + tmpFrame.size.width;
        }
    }
    return newWidth;
}
- (float)getMinxPointForBorderedView:(BorderedView *)borderedView {
    float minX = borderedView.frame.size.width;
    for(BorderedViewSubview *subview in borderedView.artificiallSubviews) {
        if(subview.frame.origin.x < minX){
            minX = subview.frame.origin.x;
        }
    }
    return minX;
}
- (float)leftSpaceForBorderedView:(BorderedView *)borderedView {
    float leftSpace = (borderedView.frame.size.width - ([self getLastPointForBorderedView:borderedView] - [self getMinxPointForBorderedView:borderedView]))/2.0;
    return roundf(leftSpace);
}

#pragma mark - Generating subvies

- (void)generateSubviewsForBorderedView:(BorderedView *)borderedView {
    NSArray *subviews = [[_buttonsDic objectForKey:borderedView.name] objectForKey:kBBSubviews];
    for(NSDictionary *subviewData in subviews){
        CGRect frame = [self frameWithFormatedDic:[subviewData objectForKey:kBBFrame]];
        float x = frame.origin.x;
        float y = frame.origin.y;
        float width = frame.size.width;
        float height = frame.size.height;
        if(height == 0) {
            height = borderedView.frame.size.height;
        }
        if(x == 0) {
            x = [self getLastPointForBorderedView:borderedView];
        }
        frame = CGRectMake(x, y, width, height);
        id subview = [[NSClassFromString([subviewData objectForKey:kBBSubviewClass]) alloc] initWithFrame:frame];
        [subview setValue:[subviewData objectForKey:kBBName] forKey:@"name"];
        [self updateSubview:subview forBorderedView:borderedView forState:NormalState];
        [subview setUserInteractionEnabled:NO];
        [borderedView.artificiallSubviews addObject:subview];
    }
    
}


@end
