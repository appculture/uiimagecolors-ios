//
//  AppDelegate.h
//  Globus
//
//  Created by Yves Bannwart-Landert on 16.01.12.
//  Copyright (c) 2012 youngculture ag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) IBOutlet UITabBarController *tabBarController;

@end
