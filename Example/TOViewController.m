//
//  TOViewController.m
//  TOWebViewControllerExample
//
//  Created by Tim Oliver on 6/05/13.
//  Copyright (c) 2013 Tim Oliver. All rights reserved.
//

#import "TOViewController.h"
#import "TOModalWebViewController.h"

@interface TOViewController ()

@end

@implementation TOViewController

- (IBAction)openButtonTapped:(id)sender
{
    TOModalWebViewController *webViewController = [[TOModalWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    webViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:webViewController animated:YES completion:nil];
}

@end
