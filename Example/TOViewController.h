//
//  TOViewController.h
//  TOWebViewControllerExample
//
//  Created by Tim Oliver on 6/05/13.
//  Copyright (c) 2013 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TOViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *presentModalButton;
@property (strong, nonatomic) IBOutlet UIButton *pushNavigationControllerButton;

- (IBAction)presentModalButtonTapped:(id)sender;
- (IBAction)pushToNavigationButtonTapped:(id)sender;

@end
