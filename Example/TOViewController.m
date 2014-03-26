//
//  TOViewController.m
//  TOWebViewControllerExample
//
//  Created by Tim Oliver on 6/05/13.
//  Copyright (c) 2013 Tim Oliver. All rights reserved.
//

#import "TOViewController.h"
#import "TOWebViewController.h"

#ifndef NSFoundationVersionNumber_iOS_6_1
    #define NSFoundationVersionNumber_iOS_6_1  993.00
#endif

/* Detect if we're running iOS 7.0 or higher */
#define MINIMAL_UI (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)

@interface TOViewController ()

@end

@implementation TOViewController

- (void)viewDidLoad
{
    self.title = @"TOWebViewController";
    
    if (MINIMAL_UI) {
        self.view.backgroundColor = [UIColor whiteColor];
    
        //Offset the buttons by the height of the navigation bar
        CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
        self.presentModalButton.frame = CGRectOffset(self.presentModalButton.frame, 0.0f, navBarHeight);
        self.pushNavigationControllerButton.frame = CGRectOffset(self.pushNavigationControllerButton.frame, 0.0f, navBarHeight);
    }
}

- (IBAction)presentModalButtonTapped:(id)sender
{
    TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://apple.com/"]];
    [self presentViewController:webViewController animated:YES completion:nil];
}

- (IBAction)pushToNavigationButtonTapped:(id)sender
{
    TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://apple.com/"]];
    [self.navigationController pushViewController:webViewController animated:YES];
}

@end
