//
//  TOModalWebViewController.h
//  TOModalWebViewControllerExample
//
//  Created by Tim Oliver on 6/05/13.
//  Copyright (c) 2013 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TOModalWebViewController : UIViewController

- (id)initWithURL: (NSURL *)url;

/* Get/set the current URL being displayed */
@property (nonatomic,strong) NSURL *url;

/*  The navigation bar will move out of view when the user scrolls down.
    It will reappear when the user scrolls up at all (iPhone screen-szie only) */
@property (nonatomic,assign) BOOL fullScreenWebView;



@end
