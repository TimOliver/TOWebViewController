//
//  TOModalWebViewController.m
//
//  Created by Tim Oliver on 6/05/13.
//  Copyright (c) 2013 Timothy Oliver. All rights reserved.
//

#import "TOModalWebViewController.h"
#import <QuartzCore/QuartzCore.h>

#define NAVIGATION_BUTTON_WIDTH     31
#define NAVIGATION_BUTTON_SIZE      CGSizeMake(31,31)
#define NAVIGATION_BUTTON_SPACING   5

#define NAVIGATION_BAR_HEIGHT       44.0f

#define NAVIGATION_TOGGLE_ANIM_TIME 0.3

#pragma mark -
#pragma mark Hidden Properties/Methods
@interface TOModalWebViewController () <UIWebViewDelegate,UIScrollViewDelegate>

/* Navigation bar shown along the top of the view */
@property (nonatomic,strong) UINavigationBar *navigationBar;

/* The web view where all the magic happens */
@property (nonatomic,strong) UIWebView *webView;

@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UIButton *forwardButton;
@property (nonatomic,strong) UIButton *reloadStopButton;

@property (nonatomic,strong) UIImage *reloadIcon;
@property (nonatomic,strong) UIImage *stopIcon;

@property (nonatomic,strong) UIButton *doneButton;

- (void)refreshButtonsState;

- (void)backButtonTapped:(id)sender;
- (void)forwardButtonTapped:(id)sender;
- (void)reloadStopButtonTapped:(id)sender;
- (void)doneButtonTapped:(id)sender;

@end

// -------------------------------------------------------

#pragma mark -  
#pragma mark Class Implementation
@implementation TOModalWebViewController

- (id)initWithURL:(NSURL *)url
{
    if (self = [super init])
    {
        self.url = url;
    }
    
    return self;
}

- (void)loadView
{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    //Create the all-encompassing container view
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    view.opaque = YES;
    self.view = view;
    
    //Create the web view
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scalesPageToFit = YES;
    self.webView.clipsToBounds = NO;
    self.webView.scrollView.clipsToBounds = NO;
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(NAVIGATION_BAR_HEIGHT, 0, 0, 0);
    self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(NAVIGATION_BAR_HEIGHT, 0, 0, 0);
    self.webView.scrollView.delegate = self;
    [self.view addSubview:self.webView];
    
    //Create the navigation bar
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(self.view.frame),NAVIGATION_BAR_HEIGHT)];
    self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.navigationBar];
    
    //Set up the custom skinning for the navigation bar
    UIImage *navigationBarImage = [[UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebNavigationBarBG.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)];
    [self.navigationBar setBackgroundImage:navigationBarImage forBarMetrics:UIBarMetricsDefault];
    
    //set up custom styling for the navigation bar
    self.navigationBar.titleTextAttributes = @{UITextAttributeFont:[UIFont boldSystemFontOfSize:17.0f],
                                               UITextAttributeTextColor:[UIColor colorWithWhite:0.3f alpha:1.0f],
                                               UITextAttributeTextShadowOffset:[NSValue valueWithCGSize:CGSizeMake(0.0f,1.0f)],
                                               UITextAttributeTextShadowColor:[UIColor colorWithWhite:1.0f alpha:0.4f]};
    
    //set up the buttons for the navigation bar
    CGRect buttonFrame; buttonFrame.size = NAVIGATION_BUTTON_SIZE;
    UIImage *buttonPressedImage = [UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebViewIconPressedBG.png"]];
    
    UIImage *backButtonImage = [UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebViewBackIcon.png"]];
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame: buttonFrame];
    [self.backButton setImage:backButtonImage forState:UIControlStateNormal];
    [self.backButton setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    
    UIImage *forwardButtonImage = [UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebViewForwardIcon.png"]];
    self.forwardButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forwardButton setFrame:buttonFrame];
    [self.forwardButton setImage:forwardButtonImage forState:UIControlStateNormal];
    [self.forwardButton setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    
    self.reloadIcon = [[UIImage alloc] initWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebViewRefreshIcon.png"]];
    self.stopIcon   = [[UIImage alloc] initWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebViewStopIcon.png"]];
    
    self.reloadStopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.reloadStopButton setFrame:buttonFrame];
    [self.reloadStopButton setImage:self.reloadIcon forState:UIControlStateNormal];
    [self.reloadStopButton setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    //remove the bottom shadow from the webview
    for (UIView *view in self.webView.scrollView.subviews)
    {
        if ([view isKindOfClass:[UIImageView class]] && CGRectGetWidth(view.frame) == CGRectGetWidth(self.view.frame))
        {
            [view removeFromSuperview];
            break;
        }
    }
    
    CGRect buttonFrame = CGRectZero; buttonFrame.size = NAVIGATION_BUTTON_SIZE;
    
    //set up the icons for the navigation bar
    UIView *iconsContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (NAVIGATION_BUTTON_WIDTH*2)+NAVIGATION_BUTTON_SPACING, NAVIGATION_BUTTON_WIDTH)];
    iconsContainerView.backgroundColor = [UIColor clearColor];
    
    //add the back button
    self.backButton.frame = buttonFrame;
    [iconsContainerView addSubview:self.backButton];
    
    //add the reload button
    buttonFrame.origin.x = NAVIGATION_BUTTON_WIDTH + NAVIGATION_BUTTON_SPACING;
    self.reloadStopButton.frame = buttonFrame;
    [iconsContainerView addSubview:self.reloadStopButton];
    
    //add the forward button too, but keep it hidden for now
    self.forwardButton.frame = buttonFrame;
    self.forwardButton.hidden = YES;
    [iconsContainerView addSubview:self.forwardButton];
    
    //push the buttons on the left to this controller's navigation item
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconsContainerView];

    //create the 'Done' button
    UIImage *doneButtonBG           = [[UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebViewButtonBG.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
    UIImage *doneButtonBGPressed    = [[UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"ModalWebViewButtonBGPressed.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Modal Web View Controller Close") style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
    [self.navigationItem.rightBarButtonItem setBackgroundImage:doneButtonBG forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.rightBarButtonItem setBackgroundImage:doneButtonBGPressed forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    NSDictionary *textAttributes = @{UITextAttributeTextColor:[UIColor colorWithWhite:0.31f alpha:1.0f],
                                     UITextAttributeTextShadowOffset:[NSValue valueWithCGSize:CGSizeMake(0.0f, 1.0f)],
                                     UITextAttributeTextShadowColor:[UIColor colorWithWhite:1.0f alpha:0.75f]};
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:textAttributes forState:UIControlStateHighlighted];
    
    //push the navigation item to the navigation bar
    [self.navigationBar pushNavigationItem:self.navigationItem animated:NO];
    
    //Set the appropriate actions to the buttons
    [self.backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton addTarget:self action:@selector(forwardButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.reloadStopButton addTarget:self action:@selector(reloadStopButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

#pragma mark -
#pragma mark State Handling
- (void)refreshButtonsState
{
    //Toggle the stop/reload button
    if (self.webView.isLoading == NO)
        [self.reloadStopButton setImage:self.reloadIcon forState:UIControlStateNormal];
    else
        [self.reloadStopButton setImage:self.stopIcon forState:UIControlStateNormal];
    
    //update the state for the back button
    if (self.webView.canGoBack)
        [self.backButton setEnabled:YES];
    else
        [self.backButton setEnabled:NO];
    
    //update the state for the forward button
    if (self.webView.canGoForward && self.forwardButton.hidden)
    {
        UIView *containerView = self.forwardButton.superview;
        
        self.forwardButton.alpha = 0.0f;
        self.forwardButton.hidden = NO;
        
        [UIView animateWithDuration:NAVIGATION_TOGGLE_ANIM_TIME animations:^{
            //make the forward button visible
            self.forwardButton.alpha = 1.0f;
            
            //animate the container to accomodate
            CGRect frame = containerView.frame;
            frame.size.width = (NAVIGATION_BUTTON_WIDTH*3) + (NAVIGATION_BUTTON_SPACING*2);
            containerView.frame = frame;
            
            //move the reload buttons
            frame = self.reloadStopButton.frame;
            frame.origin.x = (NAVIGATION_BUTTON_WIDTH*2) + (NAVIGATION_BUTTON_SPACING*2);
            self.reloadStopButton.frame = frame;
        }];
    }
    
    if (self.webView.canGoForward == NO && self.forwardButton.hidden == NO)
    {
        UIView *containerView = self.forwardButton.superview;
        self.forwardButton.alpha = 1.0f;
        
        [UIView animateWithDuration:NAVIGATION_TOGGLE_ANIM_TIME animations:
         ^{
            //make the forward button invisible
            self.forwardButton.alpha = 0.0f;
            
            //animate the container to accomodate
            CGRect frame = containerView.frame;
            frame.size.width = (NAVIGATION_BUTTON_WIDTH*2) + (NAVIGATION_BUTTON_SPACING);
            containerView.frame = frame;
            
            //move the reload buttons
            frame = self.reloadStopButton.frame;
            frame.origin.x = (NAVIGATION_BUTTON_WIDTH) + (NAVIGATION_BUTTON_SPACING);
            self.reloadStopButton.frame = frame;
        }
        completion:^(BOOL completion)
        {
            self.forwardButton.hidden = YES;
        }];
    }
}

#pragma mark -
#pragma mark WebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self refreshButtonsState];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self refreshButtonsState];
    
    //NSLog(@"%f",self.webView.scrollView.contentOffset.y);
    
    //set the navigation bar title
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    //reset the scroll view if it's going past the top
    //if (self.webView.scrollView.contentOffset.y == -NAVIGATION_BAR_HEIGHT)
    //self.webView.scrollView.contentOffset = CGPointZero;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self refreshButtonsState];
}

#pragma mark -
#pragma mark WebView ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //bit of a hack, if the scrollview snaps to <= 1 (eg, the user didn't do it, and it didn't animate), lock it back to the proper origin
    if (scrollView.contentOffset.y <= 1.0f + FLT_EPSILON && scrollView.dragging == NO && scrollView.decelerating == NO && [scrollView.layer animationForKey:@"bounds"] == nil)
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x,-NAVIGATION_BAR_HEIGHT);
}

#pragma mark -
#pragma mark Button Callbacks
- (void)backButtonTapped:(id)sender
{
    [self.webView goBack];
    [self refreshButtonsState];
}

- (void)forwardButtonTapped:(id)sender
{
    [self.webView goForward];
    [self refreshButtonsState];
}

- (void)reloadStopButtonTapped:(id)sender
{
    if (self.webView.isLoading)
        [self.webView stopLoading];
    else
        [self.webView reload];
    
    [self refreshButtonsState];
}

- (void)doneButtonTapped:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}



@end
