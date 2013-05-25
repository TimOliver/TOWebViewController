//
//  TOViewController.m
//  TOWebViewControllerExample
//
//  Created by Tim Oliver on 6/05/13.
//  Copyright (c) 2013 Tim Oliver. All rights reserved.
//

#import "TOViewController.h"
#import "TOWebViewController.h"

@interface TOViewController ()

@end

@implementation TOViewController

- (void)viewDidLoad
{
    
}

- (IBAction)openButtonTapped:(id)sender
{
    TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://apple.com/"]];
    webViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:webViewController animated:YES completion:nil];
}

@end
