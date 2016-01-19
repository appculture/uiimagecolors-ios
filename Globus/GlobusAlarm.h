//
//  GlobusAlarm.h
//  Globus
//
//  Created by Patrik Oprandi on 14.12.12.
//
//

#import <Foundation/Foundation.h>

@class Coupon;

#define kAlarmTimeForExpiredDates (-7*24*60*60)+(10*60*60)

@interface GlobusAlarm : NSObject

@property (nonatomic, strong) Coupon *object;
@property (nonatomic) NSTimeInterval alarmTimeInterval;
@property (nonatomic, strong) UILocalNotification *notification;

- (id)initWithObject:(Coupon *)theObject;

- (void)schedule;
- (void)show;
- (void)cancel;
- (void)cancelNotificationById:(Coupon *)theObject;
- (void)cancelAllNotifications;
- (BOOL)isNotificationAlreadySet:(Coupon *)theObject;

@end
