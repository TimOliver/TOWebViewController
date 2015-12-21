//
//  TOWebViewControllerTests.m
//  TOWebViewControllerTests
//
//  Created by Tim Oliver on 14/06/2015.
//  Copyright (c) 2016 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TOWebViewController.h"

@interface TOWebViewControllerTests : XCTestCase

@end

@implementation TOWebViewControllerTests

- (void)testViewControllerInstance {
    TOWebViewController *controller = [[TOWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://www.apple.com"]];
    UIView *view = controller.view;
    XCTAssert(view != nil, @"Pass");
}

@end
