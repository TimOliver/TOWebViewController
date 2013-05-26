//
//  TOWebViewController.m
//
//  Copyright 2013 Timothy Oliver. All rights reserved.
//
//  Features logic designed by Satoshi Asano (ninjinkun) for NJKWebViewProgress,
//  also licensed under the MIT License. Re-implemented by Timothy Oliver.
//  https://github.com/ninjinkun/NJKWebViewProgress
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOWebViewController.h"
#import "TOWebViewControllerPopoverView.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <Twitter/Twitter.h>

/* Navigation Bar Properties */
#define NAVIGATION_BUTTON_WIDTH             31
#define NAVIGATION_BUTTON_SIZE              CGSizeMake(31,31)
#define NAVIGATION_BUTTON_SPACING           5
#define NAVIGATION_BUTTON_SPACING_IPAD      12
#define NAVIGATION_BAR_HEIGHT               44.0f
#define NAVIGATION_TOGGLE_ANIM_TIME         0.3

/* The distance down from the top of the scrollview,
    that must be scrolled before the rotation animation
    aligns to the middle, and not along the top */
#define CONTENT_OFFSET_THRESHOLD    20

/* Hieght of the loading progress bar view */
#define LOADING_BAR_HEIGHT          2

/* Unique URL triggered when JavaScript reports page load is complete */
NSString *kCompleteRPCURL = @"webviewprogress:///complete";

/* Default load values to defer to during the load process */
static const float kInitialProgressValue                = 0.1f;
static const float kBeforeInteractiveMaxProgressValue   = 0.5f;
static const float kAfterInteractiveMaxProgressValue    = 0.9f;

#pragma mark -
#pragma mark Hidden Properties/Methods
@interface TOWebViewController () <UIWebViewDelegate,
                                    TOWebViewControllerPopoverViewDelegate,
                                    UIPopoverControllerDelegate,
                                    MFMailComposeViewControllerDelegate,
                                    MFMessageComposeViewControllerDelegate>
{
    
    //Save the state of the web view before we rotate so we can properly re-align it afterwards
    struct {
        CGSize     frameSize;
        CGSize     contentSize;
        CGPoint    contentOffset;
        CGFloat    zoomScale;
        CGFloat    minimumZoomScale;
        CGFloat    maximumZoomScale;
    } _webViewState;
    
    //State tracking for load progress of current page
    struct {
        NSInteger   loadingCount;       //Number of requests concurrently being handled
        NSInteger   maxLoadCount;       //Maximum number of load requests that was reached
        BOOL        interactive;        //Load progress has reached the point where users may interact with the content
        CGFloat     loadingProgress;    //Between 0.0 and 1.0, the load progress of the current page
    } _loadingProgressState;
}

/* The label for the title view along the navigation bar */
@property (nonatomic,strong) UILabel *titleLabelView;

/* Gradient layer added to the background view for a bit of extra detail */
@property (nonatomic,strong) CAGradientLayer *gradientLayer;

/* Navigation bar shown along the top of the view */
@property (nonatomic,strong) UINavigationBar *navigationBar;

/* The web view where all the magic happens */
@property (nonatomic,strong) UIWebView *webView;

/* The loading bar, displayed when a page is being loaded */
@property (nonatomic,strong) UIView *loadingBarView;

/* A snapshot of the web view, shown when rotating */
@property (nonatomic,strong) UIImageView *webViewRotationSnapshot;

/* Metrics for sizing + placing control buttons in the navigation bar */
@property (nonatomic,assign) CGFloat buttonWidth;
@property (nonatomic,assign) CGFloat buttonSpacing;

/* Buttons to be displayed on the left in the navigation bar*/
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UIButton *forwardButton;
@property (nonatomic,strong) UIButton *reloadStopButton;
@property (nonatomic,strong) UIButton *actionButton;

/* The reload icon and stop icon will share the same icon */
@property (nonatomic,strong) UIImage *reloadIcon;
@property (nonatomic,strong) UIImage *stopIcon;

/* The dismissal button displayed on the right of the nav bar. */
@property (nonatomic,strong) UIButton *doneButton;

/* Popover View Handlers */
@property (nonatomic,strong) TOWebViewControllerPopoverView *actionPopoverView;
@property (nonatomic,strong) UIPopoverController *sharingPopoverController;

/* Review the current state of the web view and update the UI controls in the nav bar to match it */
- (void)refreshButtonsState;

/* Event callbacks for button taps */
- (void)backButtonTapped:(id)sender;
- (void)forwardButtonTapped:(id)sender;
- (void)reloadStopButtonTapped:(id)sender;
- (void)actionButtonTapped:(id)sender;
- (void)doneButtonTapped:(id)sender;

/* Event handlers for items in the 'action' popup */
- (void)openSharingDialog;
- (void)openInBrowser;
- (void)openMailDialog;
- (void)openMessageDialog;
- (void)openTwitterDialog;

/* Methods related to tracking load progress of current page */
- (void)resetLoadProgress;
- (void)startLoadProgress;
- (void)incrementLoadProgress;
- (void)finishLoadProgress;
- (void)setLoadingProgress:(CGFloat)loadingProgress;
- (void)handleLoadRequestCompletion; //Called each time a request successfully (or unsuccessfully) ends

/* Methods to contain all of the functionality needed to properly animate the UIWebView rotating */
- (CGRect)rectForVisibleRegionOfWebViewAnimatingToOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)setUpWebViewForRotationToOrientation:(UIInterfaceOrientation)toOrientation withDuration:(NSTimeInterval)duration;
- (void)animateWebViewRotationToOrientation:(UIInterfaceOrientation)toOrientation withDuration:(NSTimeInterval)duration;
- (void)restoreWebViewFromRotationFromOrientation:(UIInterfaceOrientation)fromOrientation;

/* Methods to derive state information from the web view */
- (UIView *)webViewContentView;             //pull out the actual UIView used to display the web content so we can render a snapshot from it
- (BOOL)webViewPageWidthIsDynamic;          //The page will rescale its own content if the web view frame is changed (ie DON'T play a zooming animation)
- (UIColor *)webViewPageBackgroundColor;    //try and determine the background colour of the current page

@end

// -------------------------------------------------------

#pragma mark -  
#pragma mark Class Implementation
@implementation TOWebViewController

- (id)initWithURL:(NSURL *)url
{
    if (self = [super init])
    {
        self.url = url;
        self.loadingBarTintColor = [UIColor colorWithRed:234/255.0f green:7.0f/255.0f blue:7.0f/255.0f alpha:1.0f];
        self.showActionButton = YES;
        self.buttonSpacing = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? NAVIGATION_BUTTON_SPACING : NAVIGATION_BUTTON_SPACING_IPAD;
        self.buttonWidth = NAVIGATION_BUTTON_WIDTH;
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
    
    //add a gradient to the background view
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.colors = @[(id)[[UIColor colorWithWhite:0.0f alpha:0.0f] CGColor],(id)[[UIColor colorWithWhite:0.0f alpha:0.35f] CGColor]];
    self.gradientLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.gradientLayer];
    
    //Create the web view
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-NAVIGATION_BAR_HEIGHT)];
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scalesPageToFit = YES;
    self.webView.contentMode = UIViewContentModeRedraw;
    self.webView.opaque = YES;
    [self.view addSubview:self.webView];
  
    //Create the navigation bar
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(self.view.frame),NAVIGATION_BAR_HEIGHT)];
    self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.navigationBar];
    
    //Set up the custom skinning for the navigation bar
    UIImage *navigationBarImage = [[UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"TOWebViewControllerNavigationBarBG.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)];
    [self.navigationBar setBackgroundImage:navigationBarImage forBarMetrics:UIBarMetricsDefault];
    
    //set up a custom label for the title
    self.titleLabelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.navigationBar.frame.size.width, 44.0f)];
    self.titleLabelView.backgroundColor = [UIColor clearColor];
    self.titleLabelView.textColor = [UIColor colorWithWhite:0.3f alpha:1.0f];
    self.titleLabelView.font = [UIFont boldSystemFontOfSize:17.0f];
    self.titleLabelView.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    self.titleLabelView.shadowOffset = CGSizeMake(0.0f,1.0f);
    self.titleLabelView.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = self.titleLabelView;
  
    //Set up the loading bar
    CGFloat maxWidth = MAX(CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame));
    self.loadingBarView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationBar.frame), maxWidth, LOADING_BAR_HEIGHT)];
    self.loadingBarView.backgroundColor = self.loadingBarTintColor;
    
    //set up a subtle gradient to add over the loading bar
    CAGradientLayer *loadingBarGradientLayer = [CAGradientLayer layer];
    loadingBarGradientLayer.colors = @[(id)[[UIColor colorWithWhite:0.0f alpha:0.25f] CGColor],(id)[[UIColor colorWithWhite:0.0f alpha:0.0f] CGColor]];
    loadingBarGradientLayer.frame = self.loadingBarView.bounds;
    [self.loadingBarView.layer addSublayer:loadingBarGradientLayer];
    
    //set up the buttons for the navigation bar
    CGRect buttonFrame = CGRectZero; buttonFrame.size = NAVIGATION_BUTTON_SIZE;
    UIImage *buttonPressedImage = [UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"TOWebViewControllerIconPressedBG.png"]];
    
    UIImage *backButtonImage = [UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"TOWebViewControllerBackIcon.png"]];
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame: buttonFrame];
    [self.backButton setImage:backButtonImage forState:UIControlStateNormal];
    [self.backButton setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    
    UIImage *forwardButtonImage = [UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"TOWebViewControllerForwardIcon.png"]];
    self.forwardButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forwardButton setFrame:buttonFrame];
    [self.forwardButton setImage:forwardButtonImage forState:UIControlStateNormal];
    [self.forwardButton setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    
    self.reloadIcon = [[UIImage alloc] initWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"TOWebViewControllerRefreshIcon.png"]];
    self.stopIcon   = [[UIImage alloc] initWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"TOWebViewControllerStopIcon.png"]];
    
    if (self.showActionButton)
    {
        self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.actionButton setFrame:buttonFrame];
        [self.actionButton setImage:[UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"TOWebViewControllerActionIcon.png"]] forState:UIControlStateNormal];
        [self.actionButton setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];

    }

    //show the 'reload' button only if on iPad
    if (self.showActionButton == NO || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.reloadStopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.reloadStopButton setFrame:buttonFrame];
        [self.reloadStopButton setImage:self.reloadIcon forState:UIControlStateNormal];
        [self.reloadStopButton setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    //remove the top and bottom shadows from the webview
    for (UIView *view in self.webView.scrollView.subviews)
    {
        if ([view isKindOfClass:[UIImageView class]] && CGRectGetWidth(view.frame) == CGRectGetWidth(self.view.frame))
        {
            [view removeFromSuperview];
            break;
        }
    }
    
    CGRect buttonFrame = CGRectZero; buttonFrame.size = NAVIGATION_BUTTON_SIZE;
    
    CGFloat width = (self.buttonWidth*2)+(self.buttonSpacing*1);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || self.showActionButton)
        width = (self.buttonWidth*3)+(self.buttonSpacing*1);
    
    //set up the icons for the navigation bar
    UIView *iconsContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, self.buttonWidth)];
    iconsContainerView.backgroundColor = [UIColor clearColor];
    
    //add the back button
    self.backButton.frame = buttonFrame;
    [iconsContainerView addSubview:self.backButton];
    
    //add the forward button too, but keep it hidden for now
    buttonFrame.origin.x = self.buttonWidth + self.buttonSpacing;
    self.forwardButton.frame = buttonFrame;
    self.forwardButton.hidden = YES;
    [iconsContainerView addSubview:self.forwardButton];
    
    //add the reload button if the action button is hidden
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || self.showActionButton==NO)
    {
        self.reloadStopButton.frame = buttonFrame;
        [iconsContainerView addSubview:self.reloadStopButton];
        buttonFrame.origin.x += (self.buttonWidth + self.buttonSpacing);
    }
    
    //add the action button
    if (self.showActionButton)
    {
        //if we're on iPad, we need to account for the 'reload' button
        self.actionButton.frame = buttonFrame;
        [iconsContainerView addSubview:self.actionButton];
    }
    
    //push the buttons on the left to this controller's navigation item
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconsContainerView];

    //create the 'Done' button
    UIImage *doneButtonBG           = [[UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"TOWebViewControllerButtonBG.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
    UIImage *doneButtonBGPressed    = [[UIImage imageWithContentsOfFile:[resourcePath stringByAppendingPathComponent:@"TOWebViewControllerButtonBGPressed.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 9, 9, 9)];
    
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
    [self.actionButton addTarget:self action:@selector(actionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //reset the gradient layer in case the bounds changed before display
    self.gradientLayer.frame = self.view.bounds;
    
    //start loading the initial page
    if (self.url)
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{ 
    //get the web view ready for rotation
    [self setUpWebViewForRotationToOrientation:toInterfaceOrientation withDuration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //reset the gradient layer's frame to match the new bounds
    self.gradientLayer.frame = self.view.bounds;
    
    //update the loading bar to match the proper bounds
    CGRect frame = self.loadingBarView.frame;
    frame.origin.x = -CGRectGetWidth(self.loadingBarView.frame) + (CGRectGetWidth(self.view.bounds) * _loadingProgressState.loadingProgress);
    self.loadingBarView.frame = frame;
    
    //animate the web view snapshot into the proper place
    [self animateWebViewRotationToOrientation:toInterfaceOrientation withDuration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self restoreWebViewFromRotationFromOrientation:fromInterfaceOrientation];
}

#pragma mark -
#pragma mark Manual Property Accessors
- (void)setUrl:(NSURL *)url
{
    if (self.url == url)
        return;
    
    _url = url;
    
    [self.webView stopLoading];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)setLoadingBarTintColor:(UIColor *)loadingBarTintColor
{
    if (loadingBarTintColor == self.loadingBarTintColor)
        return;
    
    _loadingBarTintColor = loadingBarTintColor;
    
    self.loadingBarView.backgroundColor = self.loadingBarTintColor;
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    self.titleLabelView.text = title;
}

#pragma mark -
#pragma mark WebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldStart = YES;
    
    //TODO: Implement TOModalWebViewController Delegate callback
    
    //if the URL is the load completed notification from JavaScript
    if ([request.URL.absoluteString isEqualToString:kCompleteRPCURL])
    {
        [self finishLoadProgress];
        return NO;
    }
    
    //If the URL contrains a fragement jump (eg an anchor tag), check to see if it relates to the current page, or another
    BOOL isFragmentJump = NO;
    if (request.URL.fragment)
    {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    
    BOOL isHTTP = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"];
    if (shouldStart && !isFragmentJump && isHTTP && isTopLevelNavigation && navigationType != UIWebViewNavigationTypeBackForward)
    {
        //Save the URL in the accessor property
        _url = [request URL];
        [self resetLoadProgress];
    }
    
    return shouldStart;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //increment the number of load requests started
    _loadingProgressState.loadingCount++;
    
    //keep track if this is the highest number of concurrent requests
    _loadingProgressState.maxLoadCount = MAX(_loadingProgressState.maxLoadCount, _loadingProgressState.loadingCount);
    
    //start tracking the load state
    [self startLoadProgress];
    
    //update the navigation bar buttons
    [self refreshButtonsState];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self handleLoadRequestCompletion];
    [self refreshButtonsState];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self handleLoadRequestCompletion];
    [self refreshButtonsState];
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

- (void)actionButtonTapped:(id)sender
{
    //set up the list of actions to display
    if (self.actionPopoverView)
    {
        [self.actionPopoverView dismissAnimated:NO];
        self.actionPopoverView = nil;
    }
    
    //create the popover view
    self.actionPopoverView = [TOWebViewControllerPopoverView new];
    self.actionPopoverView.delegate = self;
    
    //The 'Stop/Refresh' button
    TOWebViewControllerPopoverViewItem *reloadStopItem = nil;
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        reloadStopItem = [TOWebViewControllerPopoverViewItem new];
        reloadStopItem.image = self.webView.loading ? self.stopIcon : self.reloadIcon;
        reloadStopItem.action = ^(TOWebViewControllerPopoverViewItem *item) { [self reloadStopButtonTapped:nil]; };
    }
        
    //The share button
    TOWebViewControllerPopoverViewItem *sharingItem = [TOWebViewControllerPopoverViewItem new];
    sharingItem.title = NSLocalizedString(@"Share...", @"Sharing button");
    sharingItem.action = ^(TOWebViewControllerPopoverViewItem *item){ [self openSharingDialog]; };
    
    // Open in button
    BOOL chromeIsInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]];
    TOWebViewControllerPopoverViewItem *openItem = [TOWebViewControllerPopoverViewItem new];
    openItem.title = chromeIsInstalled ? NSLocalizedString(@"Open in Chrome", @"Open page in Chrome") : NSLocalizedString(@"Open in Safari", @"Open page in Safari");
    openItem.action = ^(TOWebViewControllerPopoverViewItem *item){ [self openInBrowser]; };
    
    //Copy Link button
    TOWebViewControllerPopoverViewItem *copyLinkItem = [TOWebViewControllerPopoverViewItem new];
    copyLinkItem.title = NSLocalizedString(@"Copy Link", @"Copy Link to Pasteboard");
    copyLinkItem.action = ^(TOWebViewControllerPopoverViewItem *item){ [[UIPasteboard generalPasteboard] setString:[self.webView.request.URL absoluteString]]; };
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.actionPopoverView.leftHeaderItem = reloadStopItem;
        self.actionPopoverView.rightHeaderItem = sharingItem;
        self.actionPopoverView.items = @[openItem,copyLinkItem];
    }
    else
    {
        self.actionPopoverView.items = @[openItem,copyLinkItem,sharingItem];
    }
    
    [self.actionPopoverView presentPopoverFromView:sender animated:YES];
}

- (void)webViewControllerPopoverView:(TOWebViewControllerPopoverView *)popoverView didDismissAnimated:(BOOL)animated
{
    self.actionPopoverView = nil;
}

- (void)doneButtonTapped:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Action Item Event Handlers
- (void)openSharingDialog
{
    //dismiss the present popover view
    [self.actionPopoverView dismissAnimated:NO];
    
    // If we're on iOS 6, we can use the new, super-duper activity view controller :)
    if (NSClassFromString(@"UIActivityViewController"))
    {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.url] applicationActivities:nil];
        activityViewController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard]; //we've already provided 'Copy' functionality. This is a bit redundant.
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            [self presentModalViewController:activityViewController animated:YES];
        }
        else
        {
            //UIPopoverController requires we retain our own instance of it.
            //So if we somehow have a prior instance, clean it out
            if (self.sharingPopoverController)
            {
                [self.sharingPopoverController dismissPopoverAnimated:NO];
                self.sharingPopoverController = nil;
            }
            
            //Create the sharing popover controller
            self.sharingPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
            self.sharingPopoverController.delegate = self;
            [self.sharingPopoverController presentPopoverFromRect:self.actionButton.frame inView:self.actionButton.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else //We must be on iOS 5
    {
        //Email button
        TOWebViewControllerPopoverViewItem *mailItem = [TOWebViewControllerPopoverViewItem new];
        mailItem.title  = NSLocalizedString(@"Mail", @"Send Email");
        mailItem.action = ^(TOWebViewControllerPopoverViewItem *item) { [self openMailDialog]; };
        
        //The share button
        TOWebViewControllerPopoverViewItem *messageItem = nil;
        if ([MFMessageComposeViewController canSendText])
        {
            messageItem = [TOWebViewControllerPopoverViewItem new];
            messageItem.title = NSLocalizedString(@"Message", @"Send Message");
            messageItem.action = ^(TOWebViewControllerPopoverViewItem *item){ [self openMessageDialog]; };
        }
            
        TOWebViewControllerPopoverViewItem *twitterItem = nil;
        if ([TWTweetComposeViewController canSendTweet])
        {
            twitterItem = [TOWebViewControllerPopoverViewItem new];
            twitterItem.title = NSLocalizedString(@"Tweet", @"Send a Tweet");
            twitterItem.action = ^(TOWebViewControllerPopoverViewItem *item){ [self openTwitterDialog]; };
        }
        
        NSMutableArray *items = [NSMutableArray array];
        [items addObject:mailItem];
        
        if (messageItem)
            [items addObject:messageItem];
        
        if (twitterItem)
            [items addObject:twitterItem];
        
        TOWebViewControllerPopoverView *sharePopoverView = [TOWebViewControllerPopoverView new];
        sharePopoverView.items = items;
        [sharePopoverView presentPopoverFromView:self.actionButton animated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    //Once the popover controller is dismissed, we can release our own reference to it
    self.sharingPopoverController = nil;
}

- (void)openInBrowser
{
    BOOL chromeIsInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]];
    NSURL *inputURL = self.webView.request.URL;

    if (chromeIsInstalled)
    {
        NSString *scheme = inputURL.scheme;
        
        // Replace the URL Scheme with the Chrome equivalent.
        NSString *chromeScheme = nil;
        if ([scheme isEqualToString:@"http"])
        {
            chromeScheme = @"googlechrome";
        }
        else if ([scheme isEqualToString:@"https"])
        {
            chromeScheme = @"googlechromes";
        }
        
        // Proceed only if a valid Google Chrome URI Scheme is available.
        if (chromeScheme)
        {
            NSString *absoluteString    = [inputURL absoluteString];
            NSRange rangeForScheme      = [absoluteString rangeOfString:@":"];
            NSString *urlNoScheme       = [absoluteString substringFromIndex:rangeForScheme.location];
            NSString *chromeURLString   = [chromeScheme stringByAppendingString:urlNoScheme];
            NSURL *chromeURL            = [NSURL URLWithString:chromeURLString];
            
            // Open the URL with Chrome.
            [[UIApplication sharedApplication] openURL:chromeURL];
            
            return;
        }
    }
    
    //If all else fails (Or Chrome is simply not installed), open as per usual
    [[UIApplication sharedApplication] openURL:inputURL];
}

- (void)openMailDialog
{
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    [mailViewController setMessageBody:[self.url absoluteString] isHTML:NO];
    [self presentModalViewController:mailViewController animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openMessageDialog
{
    MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
    messageViewController.messageComposeDelegate = self;
    [messageViewController setBody:[self.url absoluteString]];
    [self presentModalViewController:messageViewController animated:YES];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openTwitterDialog
{
    TWTweetComposeViewController *tweetComposer = [[TWTweetComposeViewController alloc] init];
    [tweetComposer addURL:self.url];
    [self presentModalViewController:tweetComposer animated:YES];
}


#pragma mark -
#pragma mark Page Load Progress Tracking Handlers
- (void)resetLoadProgress
{
    memset( &_loadingProgressState, 0, sizeof(_loadingProgressState));
    [self setLoadingProgress:0.0f];
}

- (void)startLoadProgress
{
    //If we haven't started loading yet, set the progress to small, but visible value
    if (_loadingProgressState.loadingProgress < kInitialProgressValue)
    {
        //reset the loading bar
        CGRect frame = self.loadingBarView.frame;
        frame.origin.x = -CGRectGetWidth(self.loadingBarView.frame);
        self.loadingBarView.frame = frame;
        self.loadingBarView.alpha = 1.0f;
        
        //add the loading bar to the view
        [self.view insertSubview:self.loadingBarView aboveSubview:self.navigationBar];
        
        //kickstart the loading progress
        [self setLoadingProgress:kInitialProgressValue];
        
        //show that loading started in the status bar
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        //set the title to the URL until we load the page properly
        NSString *url = [self.url absoluteString];
        url = [url stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        self.title = url;
        
        if (self.actionPopoverView)
            [self.actionPopoverView.leftHeaderItem setImage:self.stopIcon];
    }
}

- (void)incrementLoadProgress
{
    float progress          = _loadingProgressState.loadingProgress;
    float maxProgress       = _loadingProgressState.interactive ? kAfterInteractiveMaxProgressValue : kBeforeInteractiveMaxProgressValue;
    float remainingPercent  = (float)_loadingProgressState.loadingCount / (float)_loadingProgressState.maxLoadCount;
    float increment         = (maxProgress - progress) * remainingPercent;
    progress                = fmin((progress+increment), maxProgress);
    
    [self setLoadingProgress:progress];
}

- (void)finishLoadProgress
{
    //hide the activity indicator in the status bar
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    //reset the load progress
    [self refreshButtonsState];
    [self setLoadingProgress:1.0f];
    
    //in case it didn't succeed yet, try setting the page title again
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    //if the popover is visible, update the 'stop' button to 'refresh'
    if (self.actionPopoverView)
        [self.actionPopoverView.leftHeaderItem setImage:self.reloadIcon];
}

- (void)setLoadingProgress:(CGFloat)loadingProgress
{
    // progress should be incremental only
    if (loadingProgress > _loadingProgressState.loadingProgress || loadingProgress == 0)
    {
        _loadingProgressState.loadingProgress = loadingProgress;
        
        //Update the loading bar progress to match
        CGRect frame = self.loadingBarView.frame;
        frame.origin.x = -CGRectGetWidth(self.loadingBarView.frame) + (CGRectGetWidth(self.view.bounds) * _loadingProgressState.loadingProgress);
        
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.loadingBarView.frame = frame;
        } completion:^(BOOL finished) {
            //once loading is complete, fade it out
            if (loadingProgress >= 1.0f - FLT_EPSILON)
            {
                [UIView animateWithDuration:0.2f animations:^{
                    self.loadingBarView.alpha = 0.0f;
                }];
            }
        }];
    }
}

- (void)handleLoadRequestCompletion
{
    //decrement the number of concurrent requests
    _loadingProgressState.loadingCount--;
    
    //update the progress bar
    [self incrementLoadProgress];
    
    //Query the webview to see what load state JavaScript perceives it at
    NSString *readyState = [self.webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    //interactive means the page has loaded sufficiently to allow user interaction now
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive)
    {
        _loadingProgressState.interactive = YES;
        
        //if we're at the interactive state, attach a Javascript listener to inform us when the page has fully loaded
        NSString *waitForCompleteJS = [NSString stringWithFormat:   @"window.addEventListener('load',function() { "
                                       @"var iframe = document.createElement('iframe');"
                                       @"iframe.style.display = 'none';"
                                       @"iframe.src = '%@';"
                                       @"document.body.appendChild(iframe);"
                                       @"}, false);", kCompleteRPCURL];
        
        [self.webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
        
        //see if we can set the proper page title yet
        self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    
    BOOL isNotRedirect = self.url && [self.url isEqual:self.webView.request.mainDocumentURL];
    
    BOOL complete = [readyState isEqualToString:@"complete"];
    if (complete && isNotRedirect)
        [self finishLoadProgress];
}

#pragma mark -
#pragma mark Button State Handling
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
              if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone || self.showActionButton == NO)
                  frame.size.width = (self.buttonWidth*3) + (self.buttonSpacing*2);
              else
                  frame.size.width = (self.buttonWidth*4) + (self.buttonSpacing*3);
              containerView.frame = frame;
          
              //move the reload (and maybe also the action button)
              if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
              {
                  UIButton *button = nil;
                  if (self.showActionButton)
                      button = self.actionButton;
                  else
                      button = self.reloadStopButton;
                  
                  frame = button.frame;
                  frame.origin.x = (self.buttonWidth*2) + (self.buttonSpacing*2);
                  button.frame = frame;
              }
              else
              {
                  frame = self.reloadStopButton.frame;
                  frame.origin.x = (self.buttonWidth*2) + (self.buttonSpacing*2);
                  self.reloadStopButton.frame = frame;
                  
                  if (self.showActionButton)
                  {
                      frame = self.actionButton.frame;
                      frame.origin.x = (self.buttonWidth*3) + (self.buttonSpacing*3);
                      self.actionButton.frame = frame;
                  }
              }
          }];
    }

    if (self.webView.canGoForward == NO && self.forwardButton.hidden == NO)
    {
        UIView *containerView = self.forwardButton.superview;
        self.forwardButton.alpha = 1.0f;

        [UIView animateWithDuration:NAVIGATION_TOGGLE_ANIM_TIME animations:^{
            
             //make the forward button invisible
             self.forwardButton.alpha = 0.0f;
       
             //animate the container to accomodate
             CGRect frame = containerView.frame;
             if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone || self.showActionButton == NO)
                 frame.size.width = (self.buttonWidth*2) + (self.buttonSpacing);
             else
                 frame.size.width = (self.buttonWidth*3) + (self.buttonSpacing*2);
             containerView.frame = frame;
       
             //move the reload buttons
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                UIButton *button = nil;
                if (self.showActionButton)
                    button = self.actionButton;
                else
                    button = self.reloadStopButton;
                
                frame = button.frame;
                frame.origin.x = (self.buttonWidth) + (self.buttonSpacing);
                button.frame = frame;
            }
            else
            {
                frame = self.reloadStopButton.frame;
                frame.origin.x = (self.buttonWidth) + (self.buttonSpacing);
                self.reloadStopButton.frame = frame;
                
                if (self.showActionButton)
                {
                    frame = self.actionButton.frame;
                    frame.origin.x = (self.buttonWidth*2) + (self.buttonSpacing*2);
                    self.actionButton.frame = frame;
                }
            }

       } completion:^(BOOL completion) {
           self.forwardButton.hidden = YES;
       }];
    }
}

#pragma mark -
#pragma mark UIWebView Attrbutes
- (UIView *)webViewContentView
{
    //loop through the views inside the webview, and pull out the one that renders HTML content
    for (UIView *view in self.webView.scrollView.subviews)
    {
        if ([NSStringFromClass([view class]) rangeOfString:@"WebBrowser"].location != NSNotFound)
            return view;
    }
    
    return nil;
}

- (BOOL)webViewPageWidthIsDynamic
{
    //A bit of a crazy JavaScript that scans the HTML for a <meta name="viewport"> tag and dumps its contents
    NSString *metaDataQuery =   @"(function() {"
                                    @"var metaTags = document.getElementsByTagName('meta');"
                                    @"for (i=0; i<metaTags.length; i++) {"
                                        @"if (metaTags[i].name=='viewport') {"
                                            @"return metaTags[i].getAttribute('content');"
                                        @"}"
                                    @"}"
                                @"})()";
    
    NSString *pageViewPortContent = [self.webView stringByEvaluatingJavaScriptFromString:metaDataQuery];
    if ([pageViewPortContent length] == 0)
        return NO;
    
    //remove all white space and make sure it's all lower case
    pageViewPortContent = [[pageViewPortContent stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
    
    //check if the max page zoom is locked at 1
    if ([pageViewPortContent rangeOfString:@"maximum-scale=1"].location != NSNotFound)
        return YES;
    
    //check if zooming is intentionally disabled
    if ([pageViewPortContent rangeOfString:@"user-scalable=no"].location != NSNotFound)
        return YES;
    
    //check if width is set to align to the width of the device
    if ([pageViewPortContent rangeOfString:@"width=device-width"].location != NSNotFound)
        return YES;
    
    //check if initial scale is being forced (Apple seem to blanket apply this in Safari)
    if ([pageViewPortContent rangeOfString:@"initial-scale=1"].location != NSNotFound)
        return YES;
    
    return NO;
}

- (UIColor *)webViewPageBackgroundColor
{
    //Pull the current background colour from the web view
    NSString *rgbString = [self.webView stringByEvaluatingJavaScriptFromString:@"window.getComputedStyle(document.body,null).getPropertyValue('background-color');"];
    
    //if it wasn't found, or if it isn't a proper rgb value, just return white as the default
    if ([rgbString length] == 0 || [rgbString rangeOfString:@"rgb"].location == NSNotFound)
        return [UIColor whiteColor];
    
    //Assuming now the input is either 'rgb(255, 0, 0)' or 'rgba(255, 0, 0, 255)'
    
    //remove the 'rgba' componenet
    rgbString = [rgbString stringByReplacingOccurrencesOfString:@"rgba" withString:@""];
    //conversely, remove the 'rgb' component
    rgbString = [rgbString stringByReplacingOccurrencesOfString:@"rgb" withString:@""];
    //remove the brackets
    rgbString = [rgbString stringByReplacingOccurrencesOfString:@"(" withString:@""];
    rgbString = [rgbString stringByReplacingOccurrencesOfString:@")" withString:@""];
    //remove all spaces
    rgbString = [rgbString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //we should now have something like '0,0,0'. Split it up via the commas
    NSArray *componenets = [rgbString componentsSeparatedByString:@","];
    
    //Final output componenets
    CGFloat red, green, blue, alpha = 1.0f;
    
    //if the alpha value is 0, this indicates the RGB value wasn't actually set in the page, so just return white
    if ([componenets count] < 3 || ([componenets count] >= 4 && [[componenets objectAtIndex:3] integerValue] == 0))
        return [UIColor whiteColor];
    
    red     = (CGFloat)[[componenets objectAtIndex:0] integerValue] / 255.0f;
    green   = (CGFloat)[[componenets objectAtIndex:1] integerValue] / 255.0f;
    blue    = (CGFloat)[[componenets objectAtIndex:2] integerValue] / 255.0f;
    
    if ([componenets count] >= 4)
        alpha = (CGFloat)[[componenets objectAtIndex:3] integerValue] / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark -
#pragma mark UIWebView Interface Rotation Handler
- (CGRect)rectForVisibleRegionOfWebViewAnimatingToOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGRect  rect          = CGRectZero;
    CGPoint contentOffset = self.webView.scrollView.contentOffset;
    CGSize  contentSize   = self.webView.scrollView.contentSize;
    CGSize  webViewSize   = self.webView.bounds.size;
    CGFloat heightInPortraitMode = webViewSize.width - CGRectGetHeight(self.navigationBar.frame);
    
    //we're in portrait now, target orientation is landscape
    //(So since we're zooming in, we don't need to worry about content outside the visible boundaries)
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        //save the current scroll offset and size of the web view
        rect.origin = contentOffset;
        rect.size = webViewSize;
    }
    else //rotating from landscape to portrait. We need to make sure we capture content outside the visible region and pan it back in
    {
        if ([self webViewPageWidthIsDynamic])
        {
            //set the content offset for the view to be rendered
            rect.origin = contentOffset;
            if (contentOffset.y + heightInPortraitMode > contentSize.height )
                rect.origin.y = contentSize.height - heightInPortraitMode;
          
            rect.size.width = webViewSize.width;
            rect.size.height = heightInPortraitMode; //make it as tall as it is wide
        }
        else
        {
            //set the scroll offset
            rect.origin = contentOffset;
            
            //The height of the region we're animating to, in the same space as the current content
            CGFloat scaledHeight = heightInPortraitMode * (webViewSize.width / webViewSize.height);
            
            //assume we're animating outwards with the visible region being the center.
            //so make sure to capture everything above and below it
            rect.origin.y = (contentOffset.y+(webViewSize.height*0.5f)) - (scaledHeight*0.5f);
            
            //if this takes us past the visible region, clamp it
            if (rect.origin.y < 0.0f) 
                rect.origin.y = 0.0f;
            else if (rect.origin.y + scaledHeight > contentSize.height)
                rect.origin.y = contentSize.height - scaledHeight;
            
            rect.size.width = webViewSize.width;
            rect.size.height = scaledHeight;
        }
    }
  
    return rect;
}

/* Called outside of the animation block. All of the views are currently in their 'before' state. */
- (void)setUpWebViewForRotationToOrientation:(UIInterfaceOrientation)toOrientation withDuration:(NSTimeInterval)duration
{
    //if there's already a snapshot in place (shouldn't be possible), just in case, remove it
    if (self.webViewRotationSnapshot)
    {
        [self.webViewRotationSnapshot removeFromSuperview];
        self.webViewRotationSnapshot = nil;
    }
    
    // form sheet style controllers' bounds don't change, so implementing this is rather pointless
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.modalPresentationStyle == UIModalPresentationFormSheet)
        return;
    
    //Save the current state so we can use it to properly transition after the rotation is complete
    _webViewState.frameSize         = self.webView.frame.size;
    _webViewState.contentSize       = self.webView.scrollView.contentSize;
    _webViewState.zoomScale         = self.webView.scrollView.zoomScale;
    _webViewState.contentOffset     = self.webView.scrollView.contentOffset;
    _webViewState.minimumZoomScale  = self.webView.scrollView.minimumZoomScale;
    _webViewState.maximumZoomScale  = self.webView.scrollView.maximumZoomScale;
    
    UIView *webContentView      = [self webViewContentView];
    UIColor *backgroundColor    = [self webViewPageBackgroundColor];
    CGRect renderBounds         = [self rectForVisibleRegionOfWebViewAnimatingToOrientation:toOrientation];
    
    //generate a snapshot of the webview that we can animate more smoothly
    UIGraphicsBeginImageContextWithOptions(renderBounds.size, YES, 0.0f);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        //fill the who canvas with the web page's background colour (otherwise default colour is black)
        CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
        CGContextFillRect(context, CGRectMake(0,0,CGRectGetWidth(renderBounds),CGRectGetHeight(renderBounds)));
        //offset the scroll view by the necessary amount
        CGContextTranslateCTM(context, -renderBounds.origin.x, -renderBounds.origin.y);
        //render the webview to the context
        [webContentView.layer renderInContext:context];
        //save the image to the image view
        self.webViewRotationSnapshot = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
    }
    UIGraphicsEndImageContext();
    
    //work out the starting frame for the snapshot based on page state and current orientation
    CGRect frame = self.webView.frame;
  
    //If we're presently portrait, and animating to landscape
    if (UIInterfaceOrientationIsLandscape(toOrientation))
    {
        //If the current web page zoom is locked (eg, it's a mobile site), set an appropriate background colour and don't zoom the image
        if ([self webViewPageWidthIsDynamic])
        {
            self.webViewRotationSnapshot.backgroundColor = backgroundColor;
            self.webViewRotationSnapshot.contentMode = UIViewContentModeTop;
        }
    }
    else //if we're currently landscape and we're animating to portrait
    {
        //If the current web page zoom is locked like above, 
        if ([self webViewPageWidthIsDynamic])
        {
            self.webViewRotationSnapshot.backgroundColor = backgroundColor;
            
            //if the landscape scrolloffset is outside the bounds of the portrait mode, animate from the bottom to line it up properly
            CGFloat heightInPortraitMode = CGRectGetWidth(self.webView.frame) - CGRectGetHeight(self.navigationBar.frame);
            if (self.webView.scrollView.contentOffset.y + heightInPortraitMode > self.webView.scrollView.contentSize.height )
                self.webViewRotationSnapshot.contentMode = UIViewContentModeBottomLeft;
            else
                self.webViewRotationSnapshot.contentMode = UIViewContentModeTopLeft;
        }
        else
        {
            frame.size  = self.webViewRotationSnapshot.image.size;
        
            if( _webViewState.contentOffset.y > CONTENT_OFFSET_THRESHOLD )
            {
                //Work out the size we're rotating to
                CGFloat heightInPortraitMode = CGRectGetWidth(self.webView.frame) - CGRectGetHeight(self.navigationBar.frame);
                CGFloat scaledHeight = heightInPortraitMode * (CGRectGetWidth(self.webView.frame) / CGRectGetHeight(self.webView.frame));
                CGFloat topDelta = (scaledHeight*0.5f) - CGRectGetHeight(self.webView.frame)*0.5f;
                
                //adjust as needed to fit the top or bottom
                if (_webViewState.contentOffset.y - topDelta < 0.0f)
                    frame.origin.y = CGRectGetMinY(self.webView.frame) - _webViewState.contentOffset.y;
                else if (_webViewState.contentOffset.y + CGRectGetHeight(self.webView.frame) + topDelta > _webViewState.contentSize.height)
                    frame.origin.y = (CGRectGetMaxY(self.webView.frame) - CGRectGetHeight(frame)) + ((_webViewState.contentSize.height - CGRectGetHeight(self.webView.frame) - _webViewState.contentOffset.y));
                else //position the webview in the center
                    frame.origin.y = CGRectGetMinY(self.webView.frame) + ((CGRectGetHeight(self.webView.frame)*0.5) - CGRectGetHeight(frame)*0.5);
                    
            }
        }
    }

    self.webViewRotationSnapshot.frame = frame;
  
    [self.view insertSubview:self.webViewRotationSnapshot belowSubview:self.navigationBar];
    
    //This is a dirty, dirty, DIRTY hack. When a UIWebView's frame changes (At least on iOS 6), in certain conditions,
    //the content view will NOT resize with it. This can result in visual artifacts, such as black bars up the side,
    //and weird touch feedback like not being able to properly zoom out until the user has first zoomed in and released the touch.
    //So far, the only way I've found to actually correct this is to invoke a trivial zoom animation, and this will
    //trip the webview into redrawing its content.
    //Once the view has finished rotating, we'll figure out the proper placement + zoom scale and reset it.
    
    //This animation must be complete by the time the view rotation animation is complete, else we'll have incorrect bounds data. This will speed it up to near instant.
    self.webView.scrollView.layer.speed = 9999.0f; 
    
    CGFloat zoomScale = (self.webView.scrollView.minimumZoomScale+self.webView.scrollView.maximumZoomScale) * 0.5f; //zoom into the mid point of the scale. Zooming into either extreme doesn't work.
    [self.webView.scrollView setZoomScale:zoomScale animated:YES];
    
    //hide the webview while the snapshot is animating
    self.webView.hidden = YES;
}

/* Called within the animation block. All views will be set to their 'destination' state. */
- (void)animateWebViewRotationToOrientation:(UIInterfaceOrientation)toOrientation withDuration:(NSTimeInterval)duration
{
    /// form sheet style controllers' bounds don't change, so implemeting this is rather pointless
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.modalPresentationStyle == UIModalPresentationFormSheet)
        return;
    
    //remove all animations presently applied to the web view
    [self.webView.layer removeAllAnimations];
    [self.webView.scrollView.layer removeAllAnimations];
  
    //animate the image view rotating to the proper dimensions
    CGRect frame = self.webView.frame;
    
    //We only need to scale/translate the image view if the web page has a static width
    if ([self webViewPageWidthIsDynamic] == NO)
    {
        frame.size.height = CGRectGetWidth(self.webView.frame) * (CGRectGetHeight(self.webViewRotationSnapshot.frame)/CGRectGetWidth(self.webViewRotationSnapshot.frame));
        
        //If we're sufficiently scrolled down, animate towards the center of the view, not the top
        if (_webViewState.contentOffset.y > CONTENT_OFFSET_THRESHOLD)
        {
            //Work out the offset we're rotating to
            CGFloat heightInPortraitMode = _webViewState.frameSize.width - CGRectGetHeight(self.navigationBar.frame);
            CGFloat scaledHeight = heightInPortraitMode * (_webViewState.frameSize.width / _webViewState.frameSize.height);
            CGFloat topDelta = (scaledHeight*0.5f) - _webViewState.frameSize.height*0.5f;
            
            //adjust as needed to fit the top or bottom
            if (_webViewState.contentOffset.y - topDelta < 0.0f)
                frame.origin.y = CGRectGetMinY(self.webView.frame);
            else if (_webViewState.contentOffset.y + CGRectGetHeight(self.webView.frame) + topDelta > _webViewState.contentSize.height)
                frame.origin.y = CGRectGetMaxY(self.webView.frame) - CGRectGetHeight(frame);
            else //position the webview in the center
                frame.origin.y = (CGRectGetHeight(self.webView.frame)*0.5f) - (CGRectGetHeight(frame)*0.5f);
        }
    }
    
    self.webViewRotationSnapshot.frame = frame;
}

- (void)restoreWebViewFromRotationFromOrientation:(UIInterfaceOrientation)fromOrientation
{
    /// form sheet style controllers' bounds don't change, so implemeting this is rather pointless
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.modalPresentationStyle == UIModalPresentationFormSheet)
        return;
    
    //Side Note: When a UIWebView has just had its bounds change, its minimumZoomScale and maximumZoomScale become completely (almost arbitrarily) different.
    //But, it WILL rest back to minimumZoomScale = 1.0f, after the next time the user interacts with it.
    //For resetting the state right now (as the user hasn't touched it yet), we must use the 'different' values, and translate the original state to them.
    //---
    //So from this point, we need to 'coax' the web view content to align to the new zoom scale. The transition NEEDS to be instant,
    //but we can't use animated:NO since that won't commit the zoom properly and will cause visual glitches (ie HAS to be animated:YES).
    //So to solve this, we're accessing the core animation layer and temporarily increasing the animation speed of the scrollview.
    //The zoom event is still occurring, but it's so fast, it seems instant
    CGFloat translatedScale = ((_webViewState.zoomScale/_webViewState.minimumZoomScale) * self.webView.scrollView.minimumZoomScale);
    
    //if we ended up scrolling past the max zoom size, just extend it.
    if (translatedScale > self.webView.scrollView.maximumZoomScale)
        self.webView.scrollView.maximumZoomScale = translatedScale;
    
    [self.webView.scrollView.layer removeAllAnimations];
    
    self.webView.scrollView.layer.speed = 9999.0f;
    [self.webView.scrollView setZoomScale:translatedScale animated:YES];
    
    //Pull out the animation and attach a delegate so we can receive an event when it's finished, to clean it up properly
    CABasicAnimation *anim = [[self.webView.scrollView.layer animationForKey:@"bounds"] mutableCopy];
    if (anim == nil) //anim may be nil if the zoomScale wasn't sufficiently different to warrant an animation
    {
        [self animationDidStop:nil finished:YES];
        return;
    }
    
    [self.webView.scrollView.layer removeAnimationForKey:@"bounds"];
    [anim setDelegate:self];
    [self.webView.scrollView.layer addAnimation:anim forKey:@"bounds"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //when the rotation and animation is complete, FINALLY unhide the web view
    self.webView.hidden = NO;
    
    CGSize contentSize = self.webView.scrollView.contentSize;
    CGPoint translatedContentOffset = _webViewState.contentOffset;
    
    //if the page is a mobile site, just re-add the original content offset. It'll size itself properly
    if ([self webViewPageWidthIsDynamic])
    {
        //if the content offset expands beyond the new boundary of the view, reset it
        translatedContentOffset.y = MIN(_webViewState.contentOffset.y, (contentSize.height - CGRectGetHeight(self.webView.frame)));
        translatedContentOffset.y = MAX(_webViewState.contentOffset.y, self.webView.scrollView.contentInset.top);
    }
    else //else, determine the magnitude we zoomed in/out by and translate the scroll offset to line it up properly
    {
        CGFloat magnitude = contentSize.width / _webViewState.contentSize.width;
        translatedContentOffset.x *= magnitude;
        translatedContentOffset.y *= magnitude;
        
        //if we were sufficiently scrolled from the top, make sure to line up to the middle, not the top
        if (_webViewState.contentOffset.y > CONTENT_OFFSET_THRESHOLD)
        {
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
                translatedContentOffset.y += ((CGRectGetHeight(self.webViewRotationSnapshot.frame))*0.5f) - (CGRectGetHeight(self.webView.frame)*0.5f) + CGRectGetHeight(self.navigationBar.frame);
            else
                translatedContentOffset.y -= (CGRectGetHeight(self.webView.frame)*0.5f) - (((_webViewState.frameSize.height*magnitude)*0.5f) + CGRectGetHeight(self.navigationBar.frame));
        }   
            
        //clamp it to the actual scroll region
        translatedContentOffset.x = MAX(translatedContentOffset.x, self.webView.scrollView.contentInset.left);
        translatedContentOffset.x = MIN(translatedContentOffset.x, contentSize.width - CGRectGetWidth(self.webView.frame));
        
        translatedContentOffset.y = MAX(translatedContentOffset.y, self.webView.scrollView.contentInset.top);
        translatedContentOffset.y = MIN(translatedContentOffset.y, contentSize.height - CGRectGetHeight(self.webView.frame));
    }
    
    //apply the translated offset (Thankfully, this one doens't have to be animated in order to work properly)
    [self.webView.scrollView setContentOffset:translatedContentOffset animated:NO];
    
    //restore proper scroll speed
    self.webView.scrollView.layer.speed = 1.0f;
    
    //remove the rotation screenshot
    [self.webViewRotationSnapshot removeFromSuperview];
    self.webViewRotationSnapshot = nil;
}

@end
