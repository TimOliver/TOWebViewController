//
//  TOAppDelegate.h
//  TOWebViewControllerExample
//
//  Created by Tim Oliver on 6/05/13.
//  Copyright (c) 2013 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TOViewController;

@interface TOAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) TOViewController *viewController;

@end
